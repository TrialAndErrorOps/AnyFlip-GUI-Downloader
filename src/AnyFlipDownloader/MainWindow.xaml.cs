using System.Collections.Concurrent;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Threading;
using Microsoft.Win32;

namespace AnyFlipDownloader;

public partial class MainWindow : Window
{
    private const string CliVersion = "0.1.14";
    private const string CliResourceName = "AnyFlipDownloader.Cli.exe";

    private static readonly Regex AnsiRegex = new(@"\x1B\[[0-?]*[ -/]*[@-~]", RegexOptions.Compiled);
    private static readonly Regex PercentRegex = new(@"(?<percent>\d{1,3})\s*%", RegexOptions.Compiled);
    private static readonly Regex CountRegex = new(@"\((?<current>\d+)\s*/\s*(?<total>\d+)\)", RegexOptions.Compiled);

    private readonly DispatcherTimer _elapsedTimer;
    private readonly Stopwatch _stopwatch = new();
    private readonly ConcurrentQueue<string> _diagnostics = new();

    private CancellationTokenSource? _downloadCts;
    private Process? _process;
    private string? _lastPdfPath;

    public MainWindow()
    {
        InitializeComponent();
        OutputFolderTextBox.Text = GetDefaultOutputFolder();

        _elapsedTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
        _elapsedTimer.Tick += (_, _) => ElapsedTextBlock.Text = FormatElapsed(_stopwatch.Elapsed);

        AddActivity($"Ready. Bundled CLI version: {CliVersion}");
    }

    private void Paste_Click(object sender, RoutedEventArgs e)
    {
        if (Clipboard.ContainsText())
        {
            UrlTextBox.Text = Clipboard.GetText().Trim();
            UrlTextBox.CaretIndex = UrlTextBox.Text.Length;
        }
    }

    private void Browse_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog
        {
            Title = "Choose where the PDF should be saved",
            InitialDirectory = Directory.Exists(OutputFolderTextBox.Text)
                ? OutputFolderTextBox.Text
                : GetDefaultOutputFolder(),
            Multiselect = false
        };

        if (dialog.ShowDialog(this) == true)
        {
            OutputFolderTextBox.Text = dialog.FolderName;
        }
    }

    private async void Download_Click(object sender, RoutedEventArgs e)
    {
        if (!TryReadRequest(out var request))
        {
            return;
        }

        ResetForDownload();
        SetBusy(true);
        Directory.CreateDirectory(request.OutputFolder);

        _downloadCts = new CancellationTokenSource();
        var token = _downloadCts.Token;
        var before = SnapshotPdfs(request.OutputFolder);

        try
        {
            SetStage("Preparing downloader", "Extracting the bundled command-line tool…", indeterminate: true);
            var cliPath = await ExtractBundledCliAsync(token);

            var startInfo = new ProcessStartInfo
            {
                FileName = cliPath,
                WorkingDirectory = request.OutputFolder,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            };

            if (!string.IsNullOrWhiteSpace(request.Title))
            {
                startInfo.ArgumentList.Add("-title");
                startInfo.ArgumentList.Add(request.Title);
            }

            startInfo.ArgumentList.Add("-threads");
            startInfo.ArgumentList.Add(request.Threads.ToString());
            startInfo.ArgumentList.Add("-chunksize");
            startInfo.ArgumentList.Add(request.ChunkSize.ToString());
            startInfo.ArgumentList.Add(request.Url.AbsoluteUri);

            _process = new Process { StartInfo = startInfo, EnableRaisingEvents = true };

            AddActivity($"Starting download: {request.Url}");
            AddActivity($"Output folder: {request.OutputFolder}");
            SetStage("Starting download", "Waiting for publication metadata…", indeterminate: true);

            if (!_process.Start())
            {
                throw new InvalidOperationException("The downloader process could not be started.");
            }

            _stopwatch.Restart();
            _elapsedTimer.Start();

            var stdoutTask = PumpOutputAsync(_process.StandardOutput, isErrorStream: false, token);
            var stderrTask = PumpOutputAsync(_process.StandardError, isErrorStream: true, token);

            await _process.WaitForExitAsync();
            await Task.WhenAll(stdoutTask, stderrTask);

            token.ThrowIfCancellationRequested();

            if (_process.ExitCode != 0)
            {
                throw new InvalidOperationException(BuildCliError(_process.ExitCode));
            }

            var changedPdfs = FindChangedPdfs(request.OutputFolder, before);
            _lastPdfPath = changedPdfs.FirstOrDefault();

            SetProgress(100);
            StageTextBlock.Text = "Download complete";

            if (_lastPdfPath is null)
            {
                DetailTextBlock.Text = "The downloader finished, but no new or changed PDF was detected. Check the activity log and output folder.";
                OpenFolderButton.Visibility = Visibility.Visible;
                ActivityExpander.IsExpanded = true;
                AddActivity("Completed without detecting a new or changed PDF.");
            }
            else
            {
                DetailTextBlock.Text = Path.GetFileName(_lastPdfPath);
                OpenPdfButton.Visibility = Visibility.Visible;
                OpenFolderButton.Visibility = Visibility.Visible;
                AddActivity($"Saved: {_lastPdfPath}");
            }
        }
        catch (OperationCanceledException)
        {
            StageTextBlock.Text = "Download cancelled";
            DetailTextBlock.Text = "No further work is running.";
            AddActivity("Download cancelled.");
        }
        catch (Exception ex)
        {
            StageTextBlock.Text = "Download failed";
            DetailTextBlock.Text = ex.Message;
            ActivityExpander.IsExpanded = true;
            AddActivity($"ERROR: {ex.Message}");
            MessageBox.Show(this, ex.Message, "AnyFlip Downloader", MessageBoxButton.OK, MessageBoxImage.Error);
        }
        finally
        {
            _elapsedTimer.Stop();
            _stopwatch.Stop();
            ElapsedTextBlock.Text = FormatElapsed(_stopwatch.Elapsed);

            _process?.Dispose();
            _process = null;
            _downloadCts?.Dispose();
            _downloadCts = null;
            SetBusy(false);
        }
    }

    private void Cancel_Click(object sender, RoutedEventArgs e)
    {
        CancelDownload();
    }

    private void OpenPdf_Click(object sender, RoutedEventArgs e)
    {
        if (_lastPdfPath is not null && File.Exists(_lastPdfPath))
        {
            OpenPath(_lastPdfPath);
        }
    }

    private void OpenFolder_Click(object sender, RoutedEventArgs e)
    {
        var path = _lastPdfPath is not null ? Path.GetDirectoryName(_lastPdfPath) : OutputFolderTextBox.Text;
        if (!string.IsNullOrWhiteSpace(path) && Directory.Exists(path))
        {
            OpenPath(path);
        }
    }

    private void ClearActivity_Click(object sender, RoutedEventArgs e)
    {
        ActivityTextBox.Clear();
    }

    private void OnClosing(object? sender, CancelEventArgs e)
    {
        if (_process is null || _process.HasExited)
        {
            return;
        }

        var result = MessageBox.Show(
            this,
            "A download is still running. Cancel it and close the app?",
            "AnyFlip Downloader",
            MessageBoxButton.YesNo,
            MessageBoxImage.Warning);

        if (result == MessageBoxResult.No)
        {
            e.Cancel = true;
            return;
        }

        CancelDownload();
    }

    private void CancelDownload()
    {
        _downloadCts?.Cancel();

        try
        {
            if (_process is { HasExited: false })
            {
                _process.Kill(entireProcessTree: true);
            }
        }
        catch (InvalidOperationException)
        {
            // Process exited between the check and Kill.
        }
        catch (Win32Exception ex)
        {
            AddActivity($"Could not stop the downloader cleanly: {ex.Message}");
        }
    }

    private bool TryReadRequest(out DownloadRequest request)
    {
        request = default;

        if (!Uri.TryCreate(UrlTextBox.Text.Trim(), UriKind.Absolute, out var uri)
            || (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps)
            || !(uri.Host.Equals("anyflip.com", StringComparison.OrdinalIgnoreCase)
                 || uri.Host.EndsWith(".anyflip.com", StringComparison.OrdinalIgnoreCase))
            || uri.AbsolutePath.Split('/', StringSplitOptions.RemoveEmptyEntries).Length < 2)
        {
            ShowValidationError("Enter a valid AnyFlip publication URL, such as https://anyflip.com/abcd/efgh/.", UrlTextBox);
            return false;
        }

        var outputFolder = OutputFolderTextBox.Text.Trim();
        if (string.IsNullOrWhiteSpace(outputFolder))
        {
            ShowValidationError("Choose an output folder.", OutputFolderTextBox);
            return false;
        }

        try
        {
            outputFolder = Path.GetFullPath(Environment.ExpandEnvironmentVariables(outputFolder));
        }
        catch (Exception ex) when (ex is ArgumentException or NotSupportedException or PathTooLongException)
        {
            ShowValidationError("The output folder path is not valid.", OutputFolderTextBox);
            return false;
        }

        if (!int.TryParse(ThreadsTextBox.Text, out var threads) || threads is < 1 or > 32)
        {
            ShowValidationError("Threads must be a whole number from 1 through 32.", ThreadsTextBox);
            return false;
        }

        if (!int.TryParse(ChunkSizeTextBox.Text, out var chunkSize) || chunkSize is < 1 or > 1000)
        {
            ShowValidationError("Chunk size must be a whole number from 1 through 1000.", ChunkSizeTextBox);
            return false;
        }

        request = new DownloadRequest(uri, outputFolder, TitleTextBox.Text.Trim(), threads, chunkSize);
        return true;
    }

    private async Task<string> ExtractBundledCliAsync(CancellationToken token)
    {
        var directory = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "AnyFlipDownloader",
            "cli",
            $"v{CliVersion}");
        Directory.CreateDirectory(directory);

        var destination = Path.Combine(directory, "anyflip-downloader.exe");
        var temporary = destination + ".tmp-" + Guid.NewGuid().ToString("N");

        await using var resource = Assembly.GetExecutingAssembly().GetManifestResourceStream(CliResourceName)
            ?? throw new InvalidOperationException("The bundled downloader executable is missing from this build.");

        try
        {
            await using (var output = new FileStream(temporary, FileMode.CreateNew, FileAccess.Write, FileShare.None, 81920, useAsync: true))
            {
                await resource.CopyToAsync(output, token);
            }

            File.Move(temporary, destination, overwrite: true);
            return destination;
        }
        finally
        {
            if (File.Exists(temporary))
            {
                File.Delete(temporary);
            }
        }
    }

    private async Task PumpOutputAsync(StreamReader reader, bool isErrorStream, CancellationToken token)
    {
        var buffer = new char[1024];
        var line = new StringBuilder();

        try
        {
            while (true)
            {
                var count = await reader.ReadAsync(buffer.AsMemory(), token);
                if (count == 0)
                {
                    break;
                }

                for (var index = 0; index < count; index++)
                {
                    var character = buffer[index];
                    if (character is '\r' or '\n')
                    {
                        if (line.Length > 0)
                        {
                            await DispatchCliLineAsync(line.ToString(), isErrorStream);
                            line.Clear();
                        }
                    }
                    else if (character != '\b')
                    {
                        line.Append(character);
                    }
                }
            }

            if (line.Length > 0)
            {
                await DispatchCliLineAsync(line.ToString(), isErrorStream);
            }
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested)
        {
        }
        catch (IOException) when (token.IsCancellationRequested)
        {
        }
        catch (ObjectDisposedException) when (token.IsCancellationRequested)
        {
        }
    }

    private Task DispatchCliLineAsync(string rawLine, bool isErrorStream)
    {
        return Dispatcher.InvokeAsync(() => HandleCliLine(rawLine, isErrorStream)).Task;
    }

    private void HandleCliLine(string rawLine, bool isErrorStream)
    {
        var line = AnsiRegex.Replace(rawLine, string.Empty).Trim();
        if (line.Length == 0)
        {
            return;
        }

        if (isErrorStream && Uri.TryCreate(line, UriKind.Absolute, out var echoedUrl)
                          && (echoedUrl.Host.Equals("anyflip.com", StringComparison.OrdinalIgnoreCase)
                              || echoedUrl.Host.EndsWith(".anyflip.com", StringComparison.OrdinalIgnoreCase)))
        {
            return;
        }

        AddActivity(line);

        if (isErrorStream || line.Contains("error", StringComparison.OrdinalIgnoreCase)
                          || line.Contains("failed", StringComparison.OrdinalIgnoreCase))
        {
            _diagnostics.Enqueue(line);
        }

        if (line.Contains("Preparing to download", StringComparison.OrdinalIgnoreCase))
        {
            SetStage("Reading publication", "Retrieving page information…", indeterminate: true);
            return;
        }

        if (line.Contains("Converting to pdf", StringComparison.OrdinalIgnoreCase))
        {
            SetStage("Building PDF", "Combining downloaded pages…", indeterminate: false);
            SetProgress(Math.Max(85, DownloadProgressBar.Value));
            return;
        }

        if (line.Equals("Done", StringComparison.OrdinalIgnoreCase))
        {
            SetStage("Finalizing", "Checking the completed PDF…", indeterminate: true);
            return;
        }

        var downloading = line.Contains("Downloading", StringComparison.OrdinalIgnoreCase);
        var converting = line.Contains("Converting", StringComparison.OrdinalIgnoreCase);
        if (!downloading && !converting)
        {
            return;
        }

        if (TryParseProgress(line, out var rawPercent))
        {
            var mapped = converting
                ? 85 + (rawPercent * 0.15)
                : rawPercent * 0.85;

            SetStage(
                converting ? "Building PDF" : "Downloading pages",
                line,
                indeterminate: false);
            SetProgress(mapped);
        }
        else
        {
            SetStage(converting ? "Building PDF" : "Downloading pages", line, indeterminate: true);
        }
    }

    private static bool TryParseProgress(string line, out double percent)
    {
        var percentMatch = PercentRegex.Match(line);
        if (percentMatch.Success && double.TryParse(percentMatch.Groups["percent"].Value, out percent))
        {
            percent = Math.Clamp(percent, 0, 100);
            return true;
        }

        var countMatch = CountRegex.Match(line);
        if (countMatch.Success
            && double.TryParse(countMatch.Groups["current"].Value, out var current)
            && double.TryParse(countMatch.Groups["total"].Value, out var total)
            && total > 0)
        {
            percent = Math.Clamp(current / total * 100, 0, 100);
            return true;
        }

        percent = 0;
        return false;
    }

    private void SetStage(string stage, string detail, bool indeterminate)
    {
        StageTextBlock.Text = stage;
        DetailTextBlock.Text = detail;
        DownloadProgressBar.IsIndeterminate = indeterminate;
    }

    private void SetProgress(double percent)
    {
        var normalized = Math.Clamp(percent, 0, 100);
        DownloadProgressBar.IsIndeterminate = false;
        DownloadProgressBar.Value = normalized;
        PercentTextBlock.Text = $"{normalized:0}%";
    }

    private void SetBusy(bool busy)
    {
        DownloadButton.IsEnabled = !busy;
        CancelButton.IsEnabled = busy;
        UrlTextBox.IsEnabled = !busy;
        OutputFolderTextBox.IsEnabled = !busy;
        TitleTextBox.IsEnabled = !busy;
        ThreadsTextBox.IsEnabled = !busy;
        ChunkSizeTextBox.IsEnabled = !busy;
    }

    private void ResetForDownload()
    {
        while (_diagnostics.TryDequeue(out _))
        {
        }

        _lastPdfPath = null;
        OpenPdfButton.Visibility = Visibility.Collapsed;
        OpenFolderButton.Visibility = Visibility.Collapsed;
        DownloadProgressBar.IsIndeterminate = false;
        DownloadProgressBar.Value = 0;
        PercentTextBlock.Text = "0%";
        ElapsedTextBlock.Text = "00:00";
    }

    private void AddActivity(string text)
    {
        ActivityTextBox.AppendText($"[{DateTime.Now:HH:mm:ss}] {text}{Environment.NewLine}");
        ActivityTextBox.ScrollToEnd();
    }

    private string BuildCliError(int exitCode)
    {
        var messages = _diagnostics
            .Reverse()
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .Take(8)
            .Reverse()
            .ToArray();

        if (messages.Length == 0)
        {
            return $"The downloader exited with code {exitCode}. Expand Activity for details.";
        }

        var detail = string.Join(Environment.NewLine, messages);
        if (detail.Length > 1400)
        {
            detail = detail[^1400..];
        }

        return $"The downloader exited with code {exitCode}.{Environment.NewLine}{Environment.NewLine}{detail}";
    }

    private static Dictionary<string, PdfSnapshot> SnapshotPdfs(string folder)
    {
        if (!Directory.Exists(folder))
        {
            return new Dictionary<string, PdfSnapshot>(StringComparer.OrdinalIgnoreCase);
        }

        return Directory.EnumerateFiles(folder, "*.pdf", SearchOption.TopDirectoryOnly)
            .Select(path => new FileInfo(path))
            .ToDictionary(
                file => file.FullName,
                file => new PdfSnapshot(file.Length, file.LastWriteTimeUtc),
                StringComparer.OrdinalIgnoreCase);
    }

    private static IReadOnlyList<string> FindChangedPdfs(string folder, IReadOnlyDictionary<string, PdfSnapshot> before)
    {
        return Directory.EnumerateFiles(folder, "*.pdf", SearchOption.TopDirectoryOnly)
            .Select(path => new FileInfo(path))
            .Where(file => !before.TryGetValue(file.FullName, out var snapshot)
                           || snapshot.Length != file.Length
                           || snapshot.LastWriteUtc != file.LastWriteTimeUtc)
            .OrderByDescending(file => file.LastWriteTimeUtc)
            .Select(file => file.FullName)
            .ToArray();
    }

    private static void OpenPath(string path)
    {
        Process.Start(new ProcessStartInfo(path) { UseShellExecute = true });
    }

    private void ShowValidationError(string message, System.Windows.Controls.Control control)
    {
        MessageBox.Show(this, message, "AnyFlip Downloader", MessageBoxButton.OK, MessageBoxImage.Warning);
        control.Focus();
    }

    private static string GetDefaultOutputFolder()
    {
        var downloads = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Downloads");
        return Directory.Exists(downloads) ? downloads : Environment.CurrentDirectory;
    }

    private static string FormatElapsed(TimeSpan elapsed)
    {
        return elapsed.TotalHours >= 1
            ? $"{(int)elapsed.TotalHours:00}:{elapsed.Minutes:00}:{elapsed.Seconds:00}"
            : $"{elapsed.Minutes:00}:{elapsed.Seconds:00}";
    }

    private readonly record struct DownloadRequest(Uri Url, string OutputFolder, string Title, int Threads, int ChunkSize);
    private readonly record struct PdfSnapshot(long Length, DateTime LastWriteUtc);
}
