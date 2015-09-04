//
//  Ball.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

class Ball: SKShapeNode {
    
    var speedXFirst = CGFloat(0)
    var speedXSecond = CGFloat(0)
    var lastFloor = -1
    
    var xSpeed: CGFloat {
        get {
            return speedXFirst + speedXSecond
        }
    }
    
    var lastBoardNumber = 0
    
    private override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make()-> Ball {
        
        let ball = Ball(circleOfRadius: 30)
        ball.fillColor = SKColor(white: 1, alpha: 0.8)
        ball.strokeColor = SKColor(white: 0.8, alpha: 0.5)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width / 2)
        ball.physicsBody!.dynamic = true
        ball.physicsBody!.allowsRotation = false
        ball.userData = NSMutableDictionary()
        
        return ball
    }
    
    func freezeX() {
        self.speedXFirst = 0
        self.speedXSecond = 0
    }
}