# AlamofireRSSParser

[![CI Status](http://img.shields.io/travis/AdeptusAstartes/AlamofireRSSParser.svg?style=flat)](https://travis-ci.org/AdeptusAstartes/AlamofireRSSParser)
[![Version](https://img.shields.io/cocoapods/v/AlamofireRSSParser.svg?style=flat)](http://cocoapods.org/pods/AlamofireRSSParser)
[![License](https://img.shields.io/cocoapods/l/AlamofireRSSParser.svg?style=flat)](http://cocoapods.org/pods/AlamofireRSSParser)
[![Platform](https://img.shields.io/cocoapods/p/AlamofireRSSParser.svg?style=flat)](http://cocoapods.org/pods/AlamofireRSSParser)

## Requirements
- Xcode 11.0+
- Swift 5.1+
- Alamofire 5.0.0+

#### Legacy Swift Support
_If you need to support an earlier version of Swift, please either download the zip or point your Podfile at the coresponding tag:_

- **Swift 4.0**: tag "Swift 4.0 Final"
- **Swift 3.x**: tag "2.0.1"
- **Swift 2.2**: tag "Swift 2.2 Final"
- **Swift 2.3**: tag "Swift 2.3 Final"

The respective readme's in those tags have more explicit instructions for using tags in CocoaPods.

#### Legacy Alamofire Support
_If you need to support an earlier version of Alamofire, please either download the zip or point your Podfile at the coresponding tag:_

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


### Manually
Alternately you can add the contents of AlamofireRSSParser/Pod/Classes/ to your project and import the classes as appropriate.

## Usage

_Note: To run the example project, clone the repo, and run `pod install` from the Example directory first._

You use AlamofireRSSParser just like any other response handler in Alamofire:

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
