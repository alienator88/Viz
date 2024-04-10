# Viz
<p align="center">
  <img src="https://github.com/alienator88/Viz/assets/6263626/46db3bc2-e5ac-48e6-af45-4affe6aeb55c" width="128" height="128" />
   <br />
   <strong>Status: </strong>Maintained 
   <br />
   <strong>Version: </strong>1.1
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



## Preview
![main](https://github.com/alienator88/Viz/assets/6263626/dbab1169-7a5a-4dfd-8872-8085c10aa392)


### Text Extraction Demo
https://github.com/alienator88/Viz/assets/6263626/2b809553-0eb1-4a6e-bbb5-8404680067d8


### QR/Barcode Extraction Demo
https://github.com/alienator88/Viz/assets/6263626/b88173ce-74ec-4d80-b061-60f32fc7e470




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

## Some of my apps

[Pearcleaner](https://github.com/alienator88/Pearcleaner) - An opensource app cleaner with privacy in mind

[Sentinel](https://github.com/alienator88/Sentinel) - A GUI for controlling gatekeeper status on your mac

[Viz](https://github.com/alienator88/Viz) - Utility for extracting text from images, videos, qr/barcodes

[McBrew](https://github.com/alienator88/McBrew) - A GUI for managing your homebrew
