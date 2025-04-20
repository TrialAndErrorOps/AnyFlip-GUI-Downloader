# AnyFlip GUI Downloader
 A GUI for Lofter1's AnyFlip Downloader tool

 ## Disclaimer

Only use this tool to download books that officially allow PDFs to be downloaded.

## Background

I found Lofter1's script when trying to find a better way to download AnyFlip PDFs, saw  the confusion about how to use it on Reddit and other places, so I decided to write a GUI for it. It's pretty self explanatory and doesn't involve needing to clone or download anything additional yourself.

You can either download the .ps1 file, then run it from a powershell window, or you can download the .exe and run it. Don't trust random EXEs you find online, but this is just packaged with PS2EXE in case you don't have the technical aptitude to download and run a .ps1 file.

You do NOT need admin permissions. You do NOT need to change bypass policy to Unrestricted.

You do need to have remotesigned for the execution policy
```PowerShell
set-executionpolicy remotesigned -scope process
```

By default Lofter1's downloader is installed to your user\appdata\local\anyflip-downloader folder. The script looks for that folder and will automatically install Lofter1's AnyFlip Downloader as part of the "Download PDF" process if you don't already have the tool installed.

![image](https://github.com/user-attachments/assets/98317644-24cc-4f06-8e16-cdcaa1f197c3)

![image](https://github.com/user-attachments/assets/76a45a24-98ab-4e01-95d8-3641e6b812f7)


## How to use this tool

1: Put in the URL of the AnyFlip PDF you'd like to download.

2: Enter a custom title, or leave blank to accept the default title.

3: Enter the number of threads. Lofter1 defaults to 1 thread, but I have downloaded dozens of large PDFs using 4 threads as tests and never had a problem. More threads on large PDFs ABSOLUTELY makes a speed difference.

4: There was a lot of confusion about where the AnyFlip Downloaded actually downloaded the files. It downloads them to whatever folder you run the script from. This field just pulls in whatever folder you launched from and tells you where it is.

5: Click on "Download PDF" and it will download. I preserved Lofter1's normal progress log, as well as added a custom progress bar.

![image](https://github.com/user-attachments/assets/0373effe-843d-40ab-83d0-f27f06743b73)

6: Since people had difficulty finding the file, the script will scan the folder you launched it from for the file you just downloaded, then present you with a dialogue box asking if you want to open it now or not.

![image](https://github.com/user-attachments/assets/56217ccd-14dd-4420-99a4-56645bb3ed0f)


That's it. Enjoy your AnyFlip PDF.

