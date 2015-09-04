//
//  BoardScroll.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

class BoardScroll: BoardAbstract {
    
    static let KEY_SPEED_X = "BoardScroll.speedX"
    
    let boardHeight = CGFloat(50)
    let wheelRatio = CGFloat(0.7)
    let speed = CGFloat(100)
    let boardColor = SKColor(hue: CGFloat(23)/360.0, saturation: 0.8, brightness: 0.9, alpha: 1)
    let boardStrokeColor = SKColor(hue: CGFloat(23)/360.0, saturation: 0.8, brightness: 0.7, alpha: 1)
    let wheelColor = SKColor(hue: CGFloat(15)/360.0, saturation: 0, brightness: 1, alpha: 1)
    let wheelStrokeColor = SKColor(hue: CGFloat(15) / 360, saturation: 0.8, brightness: 0.7, alpha: 1)
    
    var boardCollideMask: UInt32!
    var speedX: CGFloat!
    
    override func newNode(boardTemplate: BoardTemplate, boardSize: CGSize) -> SKNode {
        
        boardCollideMask = boardTemplate.collideMaskFirst
        let clockWise = arc4random() % 2 == 0
        speedX = clockWise ? self.speed : -self.speed
        
        let boardWidth = boardSize.width
        let boardRadius = boardHeight / 2
        let boardAvaliableWidth = boardWidth - boardRadius * 2
        let boardPath = CGPathCreateMutable()
        CGPathAddArc(boardPath, nil, -boardAvaliableWidth / 2, CGFloat(0), boardRadius, CGFloat(-M_PI_2), CGFloat(M_PI_2), true)
        CGPathAddArc(boardPath, nil, boardAvaliableWidth / 2, CGFloat(0), boardRadius, CGFloat(M_PI_2), CGFloat(-M_PI_2), true)
        CGPathCloseSubpath(boardPath)
        
        let board = SKShapeNode(path: boardPath)
        board.name = "BoardSpring"
        board.physicsBody = SKPhysicsBody(polygonFromPath: boardPath)
        board.physicsBody!.categoryBitMask = boardCollideMask
        board.physicsBody!.dynamic = false
        board.fillColor = boardColor
        board.strokeColor = boardStrokeColor
        
        let leftWheel = newWheel(speedX)
        leftWheel.position.x = -boardAvaliableWidth / 2
        board.addChild(leftWheel)
        
        let rightWheel = newWheel(speedX)
        rightWheel.position.x = boardAvaliableWidth / 2
        board.addChild(rightWheel)
        
        return board
    }
    override func onBeginContact(board: SKNode, ball: Ball, contact: SKPhysicsContact, game: GameDelegate) {
        
        ball.speedXSecond = speedX
    }
    override func onEndContact(board: SKNode, ball: Ball, contact: SKPhysicsContact, game: GameDelegate) {
        ball.speedXSecond = 0
    }
    private func newWheel(speedX: CGFloat) -> SKNode {
        
        let wheelRadius = CGFloat(boardHeight / 2 * wheelRatio)
        let wheelPath = CGPathCreateMutable()
        CGPathAddArc(wheelPath, nil, CGFloat(0), CGFloat(0), wheelRadius, CGFloat(0), CGFloat(2 * M_PI), true)
        CGPathAddLineToPoint(wheelPath, nil, CGFloat(0), CGFloat(0))
        CGPathMoveToPoint(wheelPath, nil, 0, 0)
        
        let wheelLineX = wheelRadius / 2
        let wheelLineY = wheelRadius / 2 * 1.73
        CGPathAddLineToPoint(wheelPath, nil, -wheelLineX, wheelLineY)
        CGPathMoveToPoint(wheelPath, nil, 0, 0)
        CGPathAddLineToPoint(wheelPath, nil, -wheelLineX, -wheelLineY)
        
        let wheel = SKShapeNode(path: wheelPath, centered: true)
        wheel.lineWidth = 2.0
        wheel.fillColor = wheelColor
        wheel.strokeColor = wheelStrokeColor
        
        let radians = -speedX / (boardHeight / 2)
        wheel.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(radians, duration: NSTimeInterval(1))))
        
        return wheel
    }
}
