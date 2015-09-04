//
//  UserDefaults.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation

class UserDefaults {
    
    private static let me = UserDefaults()
    
    static func share()-> UserDefaults {
        return me
    }
    
    static let password = World.userDefaultsPassword
    
    var bestScore: Int {
        
        get {
            return UserDefaults.integerForKey("bestScore")
        }
        set {
            UserDefaults.setInteger(newValue, forKey: "bestScore")
        }
    }
    var bestScoreOnLeaderboard: Int {
        
        get {
            return UserDefaults.integerForKey("bestScoreOnLeaderboard")
        }
        set {
            UserDefaults.setInteger(newValue, forKey: "bestScoreOnLeaderboard")
        }
    }
    var playedCount: Int {
        
        get {
            return UserDefaults.integerForKey("playedCount")
        }
        set {
            UserDefaults.setInteger(newValue, forKey: "playedCount")
        }
    }
    var lastAdAtCount: Int {
        
        get {
            return UserDefaults.integerForKey("lastAdAtCount")
        }
        set {
            UserDefaults.setInteger(newValue, forKey: "lastAdAtCount")
        }
    }
    var lastStoreAlertAtCount: Int {
        get {
            return UserDefaults.integerForKey("lastStoreAlertAtCount")
        }
        set {
            UserDefaults.setInteger(newValue, forKey: "lastStoreAlertAtCount")
        }
    }
    
    private static func integerForKey(key: String)-> Int {
        let encryptValue = NSUserDefaults.standardUserDefaults().stringForKey(key)
        if encryptValue == nil {
            return 0
        }
        else {
            let textValue = AESCrypt.decrypt(encryptValue, password: UserDefaults.password)
            return textValue.toInt()!
        }
    }
    private static func setInteger(value: Int, forKey: String) {
        let textValue = String(value)
        let encryptValue = AESCrypt.encrypt(textValue, password: UserDefaults.password)
        NSUserDefaults.standardUserDefaults().setObject(encryptValue, forKey: forKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}