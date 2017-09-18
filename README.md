<p align="center">
<img src="https://raw.githubusercontent.com/ra1028/Alembic/master/Assets/Alembic_Logo.png" alt="Alembic" width="70%">
</p>
<H4 align="center">A Monadic JSON Parser</H4>
</br>

<p align="center">
<a href="https://developer.apple.com/swift"><img alt="Swift3" src="https://img.shields.io/badge/language-swift3-orange.svg?style=flat"/></a>
<a href="https://travis-ci.org/ra1028/Alembic"><img alt="Build Status" src="https://travis-ci.org/ra1028/Alembic.svg?branch=master"/></a>
<a href="https://codebeat.co/projects/github-com-ra1028-alembic"><img alt="CodeBeat" src="https://codebeat.co/badges/09cc20c0-4cba-4c78-8e20-39f41d86c587"/></a>
</p>
</br>

<p align="center">
<a href="https://cocoapods.org/pods/Alembic"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/Alembic.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-yellow.svg?style=flat"/></a>
<a href="https://github.com/apple/swift-package-manager"><img alt="Swift Package Manager" src="https://img.shields.io/badge/SwiftPM-compatible-blue.svg"/></a>
</p>
</br>

<p align="center">
<a href="https://developer.apple.com/swift/"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS%20%7C%20OSX%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-green.svg"/></a>
<a href="https://github.com/ra1028/Alembic/blob/master/LICENSE"><img alt="Lincense" src="http://img.shields.io/badge/license-MIT-000000.svg?style=flat"/></a>
</p>

---

### _Alembic_ is now __Linux Ready!__
### [Try _Alembic_ on IBM Swift Sandbox](https://swiftlang.ng.bluemix.net/#/repl?gitPackage=https:%2F%2Fgithub%2Ecom%2Fra1028%2FAlembic%2DSample%2Egit)

---

## Requirements
- Swift 3.2 / Xcode 9 or later
- OS X 10.9 or later
- iOS 9.0 or later
- watchOS 2.0 or later
- tvOS 9.0 or later
- Linux

---

## Installation

### [CocoaPods](https://cocoapods.org/)  
Add the following to your Podfile:
```ruby
use_frameworks!

target 'TargetName' do
  pod 'Alembic'
end
```

### [Carthage](https://github.com/Carthage/Carthage)  
Add the following to your Cartfile:
```ruby
github "ra1028/Alembic"
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)
Add the following to your Package.swift:
```Swift
let package = Package(
    name: "ProjectName",
    dependencies: [
        .Package(url: "https://github.com/ra1028/Alembic.git", majorVersion: 3)
    ]
)
```
