using System.Diagnostics;
using System.Windows;

namespace AnyFlipDownloader;

public partial class MainWindow
{
    private const string LofterGithubUrl = "https://github.com/Lofter1/anyflip-downloader";

    private void About_Click(object sender, RoutedEventArgs e) =>
        AboutOverlay.Visibility = Visibility.Visible;

    private void CloseAbout_Click(object sender, RoutedEventArgs e) =>
        AboutOverlay.Visibility = Visibility.Collapsed;

    private void OpenLofterGithub_Click(object sender, RoutedEventArgs e) =>
        Process.Start(new ProcessStartInfo(LofterGithubUrl) { UseShellExecute = true });
}
