//
//  World.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import SystemConfiguration

class World {
    
    static let appId = 1020929059
    static let wechatAppId = "Your own wechat appId"
    static let userDefaultsPassword = "Your own password"
    static let gadUnitId = "Your own Admob unitId"
    
    static func create() {
        
        // wechat init
        WXApi.registerApp(World.wechatAppId)
    }
    
    static func isConnected() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }

}