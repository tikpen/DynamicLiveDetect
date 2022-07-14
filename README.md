# DynamicLiveDetect

[![CI Status](https://img.shields.io/travis/tikpen/DynamicLiveDetect.svg?style=flat)](https://travis-ci.org/tikpen/DynamicLiveDetect)
[![Version](https://img.shields.io/cocoapods/v/DynamicLiveDetect.svg?style=flat)](https://cocoapods.org/pods/DynamicLiveDetect)
[![License](https://img.shields.io/cocoapods/l/DynamicLiveDetect.svg?style=flat)](https://cocoapods.org/pods/DynamicLiveDetect)
[![Platform](https://img.shields.io/cocoapods/p/DynamicLiveDetect.svg?style=flat)](https://cocoapods.org/pods/DynamicLiveDetect)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DynamicLiveDetect is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DynamicLiveDetect'
```

## Usage
    @property (nonatomic, strong) DynamicLiveDetectManager *detectManager;

    DynamicLiveDetectManager *manager = [[DynamicLiveDetectManager alloc]init];
    manager.delegate = self;
    [manager dynamicLiveDetect];
    self.detectManager = manager;
    == delegate ==
    - (void)liveDetectSuccessBase64Image:(NSString *)base64Str {
       
    }

    - (void)liveDetectFailureBase64Image:(NSString *)base64Str {
        
    }

## Author

tikpen

## License

DynamicLiveDetect is available under the MIT license. See the LICENSE file for more info.
