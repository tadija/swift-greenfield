# GreenField

## TLDR;

> File / New Startup

```sh
curl -L "tadija.net/swift-greenfield" | bash -s "CatchyName"
```

## Intro

This project is less about any specific code or implementation details and more about well defined Xcode project organization and architecture (ie. configuration, modularization, tooling, scripts etc.). It's a multi-platform project (iOS / macOS) with multiple targets (App / Widgets / Tests), supporting different environments (Dev / Live) and integrating ready to use tools (SwiftLint / SwiftFormat / SwiftGen). Code is modularized using multiple Swift packages, with "TopLevel" package orchestrating other "Packages" and producing libraries needed for product targets. Run the above command to bootstrap a new project using this project as a template, thus getting all the things previously mentioned, out of the box. Enjoy making your own "greenfield" projects!

---

`#done-for-fun`
