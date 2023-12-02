# GreenField

## TLDR;

> File / New Startup ([runs this script](Scripts/gf-bootstrap.sh)):

```sh
curl "https://raw.githubusercontent.com/tadija/swift-greenfield/main/Scripts/gf-bootstrap.sh" | bash -s "CatchyName"
```

> Configure Apple Developer Team ID ([edits this file](Config/Common.xcconfig)):

```sh
t=YOUR_TEAM_ID make set-team
```

## Intro

This project is less about any specific code or implementation details, but more about well defined and organized Xcode project architecture (ie. configuration, modularization, tooling, scripts etc.). It's a multi-platform project (iOS / macOS) with multiple targets (App / Widgets / Tests), supporting different environments (Dev / Live) and integrating ready to use tools (SwiftLint / SwiftFormat / SwiftGen). Code is modularized using Swift packages, with "TopLevel" package orchestrating other packages and producing libraries consumed by the product targets. Run the above command to bootstrap a new project using this one as a template, thus getting everything previously mentioned, out of the box. Enjoy making your own "greenfield" projects!

---

`#done-for-fun`
