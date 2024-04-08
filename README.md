# Viz
<p align="center">
  <img src="https://github.com/alienator88/Viz/assets/6263626/46db3bc2-e5ac-48e6-af45-4affe6aeb55c" width="128" height="128" />
   <br />
   <strong>Status: </strong>Maintained 
   <br />
   <strong>Version: </strong>1.0
   <br />
   <a href="https://github.com/alienator88/Viz/releases"><strong>Download</strong></a>
    · 
   <a href="https://github.com/alienator88/Viz/commits">Commits</a>
   <br />
   <br />
</p>
</br>

Extract text from images, videos, QR codes, barcodes with a simple snip mechanism.


## Features
- 100% Swift
- Small app size (~3MB)
- Very quick extraction process
- Copies to clipboard automatically, ready to paste
- Hotkeys CMD+Shift+1 and CMD+Shift+2 for starting a text or qr/barcode scan
- Shows copied text in a floating window, which can be set to auto-hide as well
- Enable or disable line breaks in the extracted text
- Append multiple text snippets to the clipboard by enabling Append option in Settings, otherwise it only holds one snippet at a time
- Launch at login option
- Custom auto-updater that pulls latest release notes and binaries from GitHub Releases (Viz should be ran from /Applications folder to avoid permission issues)



## Demo

### Text Extraction
https://github.com/alienator88/Viz/assets/6263626/1b3bae40-f87e-4474-bb17-4c5ba5ae2d4b

### QR/Barcode Extraction
https://github.com/alienator88/Viz/assets/6263626/11a9445a-8d14-411d-957d-2e8896c381d7



## Requirements
- MacOS 13.0+ (App uses some newer SwiftUI functions/modifiers which don't work on anything lower than 13.0)
- Open Viz first time by right clicking and selecting Open. This adds an exception to Gatekeeper so it doesn't complain about the app not being signed with an Apple Developer certificate


## Getting Viz

<details>
  <summary>Releases</summary>

> Pre-compiled, always up-to-date versions are available from my releases page.
</details>

<details>
  <summary>Homebrew</summary>
   
> Since I don't have a paid developer account, I can't submit to the main Homebrew cask repo.
You can still add the app via Homebrew by tapping my homebrew repo:
```
brew install alienator88/homebrew-cask/viz
```
</details>

## Thanks

Much appreciation to [Wynioux]([https://freemacsoft.net/appcleaner/](https://github.com/wynioux/macOS-GateKeeper-Helper)) for their Gatekeeper script used as inspiration.

