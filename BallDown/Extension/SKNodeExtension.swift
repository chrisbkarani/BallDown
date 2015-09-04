//
//  SKNodeExtension.swift
//  BallDown
//
//  Copyright (c) 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    
    var bind: AnyObject? {
        get {
            return self.userData?.objectForKey("@bind")
        }
        set {
            if newValue == nil {
                self.userData?.removeObjectForKey("@bind")
            }
            else {
                if self.userData == nil {
                    self.userData = NSMutableDictionary()
                }
                self.userData!.setValue(newValue, forKey: "@bind")
            }
        }
    }
        

}