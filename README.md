# Cowabunga Lite
A jailed customization toolbox for iOS 15+ on all devices.

Join the [Discord](https://discord.gg/Cowabunga) for additional support and sneak peaks.
Support us on [Patreon](https://patreon.com/Cowabunga_iOS) to be featured in the home screen and to get access to exclusive private beta builds!

## Requirements
- A Mac running MacOS 11.0 (Big Sur) or higher (Can be a virtual machine/hackintosh)
- An iOS device on iOS 15.0 or higher
- Find My must be turned off while applying (can be turned back on afterwards)

## Installing
Simply download the .zip that is for your MacOS version and run the app. Plug in your phone and start tweaking!

## Features
- WebClip Icon Theming
    - No Banner or Redirects!
    - Importing folders of app icons
    - Hide App Labels
    - Individual App Settings:
        - Set a Custom App Label
        - Choose a Custom Icon
        - Import a .png as an Icon

- Status Bar
    - Change carrier name
    - Change secondary carrier name
    - Change battery display detail
    - Change time text
    - Change date text (iPad only)
    - Change breadcrumb text
    - Show numeric WiFi/Cellular strength
    - Hide many icons in the status bar

- Springboard Options
    - Set UI Animation Speed
    - Set Lock Screen Footnote
    - Toggles:
        - Set Airdrop to Everyone
        - Enable Accessory Developer
        - Show Known WiFi Networks (iOS 15)
        - Show WiFi Debugger
        - Disable Lock After Respring
        - Disable Screen Dimming While Charging
        - Disable Low Battery Alerts
        - CC Enabled on Lock Screen
        - Mute Module in CC
        - Build Version in Status Bar

- Setup Options
    - Skip Restore Setup
    - Disable OTA Updates
    - Enable Supervision
    - Set Supervision Organization Name

## Screenshots
![TestImage](https://github.com/Avangelista/CowabungaLite/blob/5e9179372317bd636eb6d1860f60c1295fd6ab2b/Images/AppSettings.png)
<img src="/Images/Home.png" width="900" height="500"/> <img src="/Images/Explore.png" width="900" height="500"/>
<img src="/Images/Theming.png" width="900" height="500"/> <img src="/Images/AppSettings.png" width="900" height="500"/> <img src="/Images/SingleApp.png" width="900" height="500"/>
<img src="/Images/StatusBar.png" width="900" height="500"/> <img src="/Images/SpringboardOptions.png" width="900" height="500"/>
<img src="/Images/SetupOptions.png" width="900" height="500"/> <img src="/Images/Apply.png" width="900" height="500"/>

## Building
Just build like a normal Xcode project. Sign using your own team and bundle identifier. You can also build the .app file by running the command `xcodebuild CODE_SIGNING_ALLOWED=NO -scheme Cowabunga\ Lite -configuration release` inside the folder containing the xcodeproj.

## Credits
- [Avangelista](https://github.com/Avangelista) for much of the restore backend and initial UI.
- [iTech Expert](https://twitter.com/iTechExpert21) for various tweaks.
- [libimobiledevice](https://libimobiledevice.org) for restoring and device algorithms.
- [TrollTools](https://github.com/sourcelocation/TrollTools) for icon theming UI and keys for some springboard options.
- [SourceLocation](https://github.com/sourcelocation) for explore page code.
- [Cowabunga](https://github.com/leminlimez/Cowabunga) for part of the code and UI.
