//
//  CollideType.swift
//  BallDown
//
//  Copyright (c) 2015 ones. All rights reserved.
//

import Foundation

enum CollideType: Int {
    
    case Scene = 0
    case Ceil = 1
    case Floor = 2
    case Ball = 3
    case BoardStart = 4
    
    func toMask()-> UInt32 {
        return UInt32(1 << self.rawValue)
    }
    static func toMask(masks: [CollideType])-> UInt32 {
        var toMask = UInt32(0)
        for type in masks {
            toMask |= type.toMask()
        }
        return toMask
    }
}