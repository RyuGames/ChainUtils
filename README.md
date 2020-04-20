<p align="center">
<img
src="https://s3.amazonaws.com/ryu-logos/RyuIcon128x128.png"
width="128px;">
</p>

<h1 align="center">ChainUtils</h1>
<p align="center">
Light weight blockchain wallet SDK for iOS
</p>

[![Build Status](https://travis-ci.com/RyuGames/ChainUtils.svg?branch=master)](https://travis-ci.com/RyuGames/ChainUtils)
[![codecov](https://codecov.io/gh/RyuGames/ChainUtils/branch/master/graph/badge.svg)](https://codecov.io/gh/RyuGames/ChainUtils)
[![Version](https://img.shields.io/cocoapods/v/ChainUtils.svg?style=flat)](https://cocoapods.org/pods/ChainUtils)
[![License](https://img.shields.io/cocoapods/l/ChainUtils.svg?style=flat)](https://cocoapods.org/pods/ChainUtils)
[![Platform](https://img.shields.io/cocoapods/p/ChainUtils.svg?style=flat)](https://cocoapods.org/pods/ChainUtils)

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

`ChainUtils` is a light weight version of [neovmUtils](https://github.com/RyuGames/neovm-utils). 

## Installation

`ChainUtils` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ChainUtils'
```

And import it into your project with:

```
import ChainUtils
```

**Note:** `ChainUtils` requires iOS 12.0 or higher.

An example `Podfile` would look like this:

```
use_frameworks!
platform :ios, '12.0'

target :'My_App' do
  pod 'ChainUtils'
end
```

### Sub-dependencies

`ChainUtils` requires:
- [NetworkUtils](https://github.com/RyuGames/NetworkUtils) - [axios](https://github.com/axios/axios) style HTTP request package for Swift
  - [SwiftPromises](https://github.com/RyuGames/SwiftPromises) - the Ryu promises package

## License

`ChainUtils` is available under the [MIT license](./LICENSE).
