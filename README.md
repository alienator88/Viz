# Viz
<p align="center">
  <img src="https://github.com/alienator88/Viz/assets/6263626/46db3bc2-e5ac-48e6-af45-4affe6aeb55c" width="128" height="128" />
   <br />
   <strong>Status: </strong>Maintained 
   <br />
   <strong>Version: </strong>2.2
   <br />
   <a href="https://github.com/alienator88/Viz/releases"><strong>Download</strong></a>
    · 
   <a href="https://github.com/alienator88/Viz/commits">Commits</a>
   <br />
   <br />
</p>
</br>

Extract text from images, videos, QR codes, barcodes with a simple snip mechanism.
Now with a simple color picker as well.


## Features
- 100% Swift
- Small app size (~4MB)
- Very quick extraction process
- Copies to clipboard automatically, ready to paste
- Post-processing option to execute shell commands when capture is taken. Can use the captured text via `[ocr]` token within the shell commands
- Hotkeys CMD+Shift+1 and CMD+Shift+2 for starting a text or qr/barcode scan. These can be cleared out and custom hotkeys can be set by user
- Shows copied text in a floating window, which can be set to auto-hide as well
- Enable or disable line breaks in the extracted text
- Append multiple text snippets to the clipboard by enabling Append option in Settings, otherwise it only holds one snippet at a time
- Saves captures in History and persists app restarts
- Also saves History to iCloud Drive if enabled
- Launch at login option
- Custom auto-updater that pulls latest release notes and binaries from GitHub Releases (Viz should be ran from /Applications folder to avoid permission issues)



## Preview
![Screenshot 2025-03-28 at 4 01 31 PM](https://github.com/user-attachments/assets/fdf8c000-b892-4632-8404-b985931f418f)


### Text Extraction Demo (Old UI)
https://github.com/alienator88/Viz/assets/6263626/2b809553-0eb1-4a6e-bbb5-8404680067d8


### QR/Barcode Extraction Demo (Old UI)
https://github.com/alienator88/Viz/assets/6263626/b88173ce-74ec-4d80-b061-60f32fc7e470




## Requirements
- MacOS 13.0+ (App uses some newer SwiftUI functions/modifiers which don't work on anything lower than 13.0)
- Viz is now signed/notarized ~~Open Viz first time by right clicking and selecting Open. This adds an exception to Gatekeeper so it doesn't complain about the app not being signed with an Apple Developer certificate~~


## Getting Viz

<details>
  <summary>Releases</summary>

Pre-compiled, always up-to-date versions are available from my [releases](https://github.com/alienator88/Viz/releases) page.
</details>

<details>
  <summary>Homebrew</summary>

You can add the app via Homebrew:
```
brew install viz
```
</details>



## License
> [!IMPORTANT]
> Viz is licensed under Apache 2.0 with [Commons Clause](https://commonsclause.com/). This means that you can do anything you'd like with the source, modify it, contribute to it, etc., but the license explicitly prohibits any form of monetization for Viz or any modified versions of it. See full license [HERE](https://github.com/alienator88/Sentinel/blob/main/LICENSE.md)



## Thanks

Much appreciation to [Wynioux]([https://freemacsoft.net/appcleaner/](https://github.com/wynioux/macOS-GateKeeper-Helper)) for their Gatekeeper script used as inspiration.

## Some of my apps

[Pearcleaner](https://github.com/alienator88/Pearcleaner) - An opensource app cleaner with privacy in mind

[Sentinel](https://github.com/alienator88/Sentinel) - A GUI for controlling gatekeeper status on your mac

[Viz](https://github.com/alienator88/Viz) - Utility for extracting text from images, videos, qr/barcodes
