# BallDown
A full game on the Appstore - [No One Gets 100](https://itunes.apple.com/app/id1020929059?mt=8)

You can control the ball to move left or right to avoid obstacles for more scores by clicking the screen

# Requirements

- iOS 8.0+
- Swift 1.2
- Xcode 6.4

## Function

- GameCenter Leaderboard
- Wechat share, Facebook, Twitter, Sina share
- iAd, Google Admob

## Usage

You can run the game immediately. But if you want to do something more, you can edit the 'BallDown/Support/World.swift' file
```swift
class World {

    // Your own appId for the share link
    static let appId = 1020929059

    // Your own wechatAppId for the wechat share function
    static let wechatAppId = "Your own wechat appId"

    // Your own password for the NSUserDefault AES encrypt
    static let userDefaultsPassword = "Your own password"

    // Your own unitId for the google Admob  
    static let gadUnitId = "Your own Admob unitId"

}

```

## Author

HaoXiang Hu, Dalian, China

[Email: pop2ones@yahoo.com](https://mail.yahoo.com)

[Twitter: @pop2ones](https://twitter.com/pop2ones)

## Licence

MIT
