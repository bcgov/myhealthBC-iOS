# AlamofireRSSParser

[![Swift](https://img.shields.io/badge/Swift-5.3_5.4_5.5_5.6-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.3_5.4_5.5_5.6-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_Linux_Windows-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_Linux_Windows-Green?style=flat-square)
[![Version](https://img.shields.io/cocoapods/v/AlamofireRSSParser.svg?style=flat)](http://cocoapods.org/pods/AlamofireRSSParser)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![License](https://img.shields.io/cocoapods/l/AlamofireRSSParser.svg?style=flat)](http://cocoapods.org/pods/AlamofireRSSParser)
[![CI Status](http://img.shields.io/travis/AdeptusAstartes/AlamofireRSSParser.svg?style=flat)](https://travis-ci.org/AdeptusAstartes/AlamofireRSSParser)

## Requirements
- Xcode 13.3.1+
- Swift 5.6+
- Alamofire 5.5.0+

**Note: AlamofireRSSParser v4.0.0 adds support for Swift Concurrency.  Due to bugs with older Swift 5.5 compilers and Xcode versions, AlamofireRSSParser's concurrency support requires Swift 5.6.0 or Xcode 13.3.1**

#### Legacy Swift Support
_If you need to support an earlier version of Swift, please either download the zip or point your Podfile at the corresponding tag:_

- **Swift 5.0 - 5.5**: tag "3.0.0"
- **Swift 4.0**: tag "Swift 4.0 Final"
- **Swift 3.x**: tag "2.0.1"
- **Swift 2.2**: tag "Swift 2.2 Final"
- **Swift 2.3**: tag "Swift 2.3 Final"

The respective readme's in those tags have more explicit instructions for using tags in CocoaPods.

#### Legacy Alamofire Support
_If you need to support an earlier version of Alamofire, please either download the zip or point your Podfile at the corresponding tag:_

- **Alamofire 5.5**: tag "3.0.0"
- **Alamofire 4**: tag "2.2.0"

## Installation

### Cocoapods
AlamofireRSSParser is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "AlamofireRSSParser"
```

Then

```swift
import AlamofireRSSParser
```
 wherever you're using it.

**Note:  Since Alamofire is a dependency for AlamofireRSSParser, make sure you don't also include Alamofire in your Podfile.**

### Swift Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/AdeptusAstartes/AlamofireRSSParser.git", .upToNextMajor(from: "4.0.0"))
]
```

But we all know that doesn't actually work and that's not how you actually add SWPM packages despite every library on GitHub that supports SPM suggesting to do the above.  So in Xcode select `File > Add Packages` and paste this repo URL into the dialogue and select "Up to next major version".

### Manually
Alternately you can add the contents of AlamofireRSSParser/Pod/Classes/ to your project and import the classes as appropriate.

## Usage

_Note: To run the example project, clone the repo, and run `pod install` from the Example directory first._

You use AlamofireRSSParser just like any other response handler in Alamofire:

### Good old closure example:
```swift
let url = "http://feeds.foxnews.com/foxnews/latest?format=xml"

AF.request(url).responseRSS() { (response) -> Void in
    if let feed: RSSFeed = response.value {
        /// Do something with your new RSSFeed object!
        for item in feed.items {
            print(item)
        }
    }
}
```

### Swift Concurrency example:

```swift
// Swift concurrency example.
if #available(iOS 13.0, *) {
    Task.init {
        if let rss = await self.swiftConcurrencyFetch() {
            print(rss)
        }
    }
}

@available(iOS 13, *)
func swiftConcurrencyFetch() async -> RSSFeed? {
    let url = "http://feeds.foxnews.com/foxnews/latest?format=xml"
    let rss = await AF.request(url).serializingRSS().response.value
    return rss
}
```

AlamofireRSSParser returns an RSSFeed object that contains an array of RSSItem objects.

## What It Does and Doesn't Do

I think we can all admit that RSS implementations are a bit all over the place.  This project is meant to parse all of the common, high level bits of the [RSS 2.0 spec](http://cyber.law.harvard.edu/rss/rss.html) that people actually use/care about.  It is not meant to comprehensively parse **all** RSS.

RSS 2.0 spec elements that it currently parses:

- title
- link
- itemDescription
- guid
- author
- comments
- source
- pubDate
- enclosure
- category

In addition, since this is a Swift port of what was originally the backbone of [Heavy Headlines](https://itunes.apple.com/us/app/heavy-headlines-metal-news/id623879550?mt=8) it also parses portions of the [Media RSS Specification 1.5.1](http://www.rssboard.org/media-rss).  

Current elements:

- media:content
- media: thumbnail
- content: encoded

It also yanks all of the images that may be linked in the `itemDescription` (if it's HTML) and creates a nice array named `imagesFromDescription` that you can use for more image content.

If you need more elements parsed please file an issue or even better, **please contribute**!  That's why this is on GitHub.

## Author

Don Angelillo, dangelillo@gmail.com

Inspired by Thibaut LE LEVIER's awesome orginal [Block RSSParser](https://github.com/tibo/BlockRSSParser) AFNetworking Plugin.

## License

AlamofireRSSParser is available under the MIT license. See the LICENSE file for more info.
