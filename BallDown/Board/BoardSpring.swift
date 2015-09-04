//
//  BoardSpring.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

class BoardSpring: BoardAbstract {
    
    static let DATA_IMPULSE = "BoardSpring.topBoard.impluse"
    static let DATA_HAS_SPRING_IMPULSE = "BoardSpring.impluse"
    
    let topBoardImpulseY = CGFloat(100)
    let halfActionTimeStandard = NSTimeInterval(0.15)
    let boardWidth = Boards.width
    let boardHeight = Boards.height / 2
    let boardRadius = Boards.radius / 2
    let springWidth = CGFloat(40)
    let maxSpringHeight = CGFloat(30)
    let minSpringHeight = CGFloat(10)
    let springCount = 3
    let boardColor = SKColor(hue: CGFloat(50) / 360.0, saturation: 0.8, brightness: 0.9, alpha: 1)
    let boardStrokeColor = SKColor(hue: CGFloat(50) / 360.0, saturation: 0.8, brightness: 0.8, alpha: 1)
    
    var topBoardCollideMask : UInt32!
    var bottomBoardCollideMask : UInt32!
    
    override func newNode(boardTemplate: BoardTemplate, boardSize: CGSize) -> SKNode {
        
        topBoardCollideMask = boardTemplate.collideMaskFirst
        bottomBoardCollideMask = boardTemplate.collideMaskSecond
        
        let board = SKNode()
        board.name = "BoardSpring"
        
        let bottomBoard = SKShapeNode(rectOfSize: CGSize(width: boardWidth, height: boardHeight), cornerRadius: boardRadius)
        bottomBoard.name = "BoardSpring.bottomBoard"
        bottomBoard.physicsBody = SKPhysicsBody(rectangleOfSize: bottomBoard.frame.size)
        bottomBoard.physicsBody!.categoryBitMask = bottomBoardCollideMask
        bottomBoard.physicsBody!.dynamic = false
        bottomBoard.position.y = 0
        bottomBoard.fillColor = boardColor
        bottomBoard.strokeColor = boardStrokeColor
        board.addChild(bottomBoard)
        bottomBoard.bind = self
        
        let springsHeight = maxSpringHeight
        let springsWidth = boardWidth * 0.8
        let springDeltaY = springsHeight / CGFloat(springCount + 1)
        var springsDrawY = CGFloat(0)
        let springsPath = CGPathCreateMutable()
        for i in 0 ..< springCount + 2 {
            springsDrawY = CGFloat(i) * springDeltaY
            CGPathMoveToPoint(springsPath, nil, CGFloat(0), springsDrawY)
            CGPathAddLineToPoint(springsPath, nil, springWidth, springsDrawY)
            CGPathMoveToPoint(springsPath, nil, springsWidth - springWidth, springsDrawY)
            CGPathAddLineToPoint(springsPath, nil, springsWidth, springsDrawY)
        }
        let springs = SKShapeNode(path: springsPath, centered: true)
        springs.name = "BoardSpring.springs"
        springs.position.y = bottomBoard.position.y + bottomBoard.frame.height / 2 + springs.frame.height / 2
        board.addChild(springs)
        
        
        let topBoard = SKShapeNode(rectOfSize: CGSize(width: boardWidth, height: boardHeight), cornerRadius: boardRadius)
        topBoard.name = "BoardSpring.topBoard"
        topBoard.physicsBody = SKPhysicsBody(rectangleOfSize: topBoard.frame.size)
        topBoard.physicsBody!.categoryBitMask = topBoardCollideMask
        topBoard.physicsBody!.dynamic = false
        topBoard.position.y = springs.position.y + springs.frame.height / 2 + topBoard.frame.height / 2
        topBoard.fillColor = boardColor
        topBoard.strokeColor = boardStrokeColor
        topBoard.userData = NSMutableDictionary()
        topBoard.userData!.setValue(self, forKey: "board")
        topBoard.userData!.setValue(self.topBoardImpulseY, forKey: BoardSpring.DATA_IMPULSE)
        board.addChild(topBoard)
        topBoard.bind = self
        
        return board
    }
    
    override func onBeginContact(board: SKNode, ball: Ball, contact: SKPhysicsContact, game: GameDelegate) {
        
        if let impulseY = board.userData!.objectForKey(BoardSpring.DATA_IMPULSE) as? CGFloat {
            // topBoard
            
            if ball.userData!.objectForKey(BoardSpring.DATA_HAS_SPRING_IMPULSE) == nil {
                ball.userData!.setValue(true, forKey: BoardSpring.DATA_HAS_SPRING_IMPULSE)
                ball.physicsBody!.applyImpulse(CGVector(dx: 0, dy: impulseY))
                ball.runAction(SKAction.sequence([
                    SKAction.waitForDuration(NSTimeInterval(0.2)),
                    SKAction.runBlock({
                        ball.userData!.removeObjectForKey(BoardSpring.DATA_HAS_SPRING_IMPULSE)
                    })
                ]))
            }
            
            let springs: SKNode! = board.parent!.childNodeWithName("BoardSpring.springs")
            
            let topBoardPositionY = board.position.y
            let springsRawPositionY = springs.position.y
            
            let halfActionTimeF = CGFloat(halfActionTimeStandard) / (log10(game.accelerate) + 1)
            let halfActionTime = NSTimeInterval(halfActionTimeF)
            
            board.runAction(SKAction.sequence([
                SKAction.moveToY(topBoardPositionY / 2, duration: halfActionTime),
                SKAction.moveToY(topBoardPositionY, duration: halfActionTime)
            ]))
            springs.runAction(SKAction.sequence([
                SKAction.scaleYTo(0.1, duration: halfActionTime),
                SKAction.scaleYTo(1.0, duration: halfActionTime)
            ]))
            springs.runAction(SKAction.sequence([
                SKAction.fadeOutWithDuration(halfActionTime / 2),
                SKAction.waitForDuration(halfActionTime),
                SKAction.fadeInWithDuration(halfActionTime / 2)
            ]))
            springs.runAction(SKAction.sequence([
                SKAction.moveToY(boardHeight / 2 + 3, duration: halfActionTime),
                SKAction.moveToY(springsRawPositionY, duration: halfActionTime)
            ]))
        }
    }
    
    override func playCollideSound(fromFloor: Int, toFloor: Int) {
        Av.share().collide.play()
    }
}