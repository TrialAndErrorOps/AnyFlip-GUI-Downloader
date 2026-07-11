# AnyFlip Downloader GUI source build

This repository contains the complete source for the .NET WPF GUI and the GitHub Actions workflow used to publish the self-contained Windows executable.

## Requirements

- Windows 10 or Windows 11
- .NET 9 SDK
- PowerShell 7 or Windows PowerShell 5.1
- Internet access during the build so the pinned Lofter1 CLI release can be downloaded and verified

## Source structure

```text
.github/
  workflows/
    build-windows.yml
src/
  AnyFlipDownloader/
    Assets/
      App.ico
    AnyFlipDownloader.csproj
    App.xaml
    App.xaml.cs
    MainWindow.xaml
    MainWindow.xaml.cs
    MainWindow.About.cs
.gitignore
SOURCE-BUILD.md
THIRD-PARTY-NOTICES.txt
```

The `Tools` directory is generated during the build. The repository does not commit the third-party CLI executable. The build workflow downloads Lofter1's `anyflip-downloader` v0.1.14 Windows x64 release and verifies its SHA-256 hash before embedding it.

## Local build

From the repository root:

```powershell
$ErrorActionPreference = 'Stop'

$version = '0.1.14'
$expectedHash = '91d514615c8e07600bf6f98870620456263a6a7f7d5d36724f16a86702fbd0c7'
$archive = Join-Path $env:TEMP 'anyflip-downloader.tar.gz'
$extract = Join-Path $env:TEMP 'anyflip-downloader-extract'
$tools = Join-Path $PWD 'src\AnyFlipDownloader\Tools'

Invoke-WebRequest "https://github.com/Lofter1/anyflip-downloader/releases/download/v$version/anyflip-downloader_${version}_windows_amd64.tar.gz" -OutFile $archive

$actualHash = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne $expectedHash) {
    throw "CLI archive checksum mismatch. Expected $expectedHash; received $actualHash."
}

Remove-Item $extract -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $extract, $tools | Out-Null
tar.exe -xzf $archive -C $extract

$cli = Get-ChildItem $extract -Recurse -Filter 'anyflip-downloader.exe' | Select-Object -First 1
if (-not $cli) {
    throw 'The CLI executable was not present in the verified release archive.'
}

Copy-Item $cli.FullName (Join-Path $tools 'anyflip-downloader.exe') -Force

dotnet publish .\src\AnyFlipDownloader\AnyFlipDownloader.csproj `
    --configuration Release `
    --runtime win-x64 `
    --self-contained true `
    --output .\publish
```

The finished executable will be:

```text
publish\AnyFlipDownloader.exe
```

## GitHub build

The workflow in `.github/workflows/build-windows.yml` performs the same verified build on a Windows runner and publishes both:

- the self-contained Windows package
- `AnyFlipDownloader-source-v1.4.0.zip`, containing the complete checked-out source tree

## Third-party component

The embedded command-line downloader is created by Lofter1 and licensed under GPL-3.0. See `THIRD-PARTY-NOTICES.txt` and the upstream repository for details.