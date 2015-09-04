//
//  BoardStick.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

class BoardSticks: BoardAbstract {
    
    let boardRadius = Boards.radius
    let stickWidth = 20
    let stickHeight = 25
    let stickColor = SKColor(hue: CGFloat(0) / 360.0, saturation: 0.15, brightness: 0.9, alpha: 1)
    let stickStrokeColor = SKColor(hue: CGFloat(0) / 360.0, saturation: 0.15, brightness: 0.7, alpha: 1)
    
    var boardCollideMask: UInt32!
    var stickCollideMask: UInt32!
    
    
    override func newNode(boardTemplate: BoardTemplate, boardSize: CGSize) -> SKNode {
        
        boardCollideMask = boardTemplate.collideMaskFirst
        stickCollideMask = boardTemplate.collideMaskSecond
        
        let board = SKShapeNode(rectOfSize: boardSize, cornerRadius: boardRadius)
        board.name = "BoardStick.board"
        board.physicsBody = SKPhysicsBody(rectangleOfSize: board.frame.size)
        board.physicsBody!.categoryBitMask = boardCollideMask
        board.physicsBody!.dynamic = false
        board.position.x = board.frame.width / 2
        board.fillColor = Boards.normalBoardColor
        board.strokeColor = Boards.normalBoardStrokeColor
        board.bind = self
        
        let boardAvaliableWidth = board.frame.width - boardRadius * 2
        let sticks = makeSticks(boardAvaliableWidth)
        sticks.name = "BoardStick.sticks"
        sticks.userData = NSMutableDictionary()
        sticks.userData!.setValue(self, forKey: Boards.DATA_BOARD_NAME)
        sticks.position.x = -sticks.frame.width / 2
        sticks.position.y = board.frame.height / 2
        sticks.fillColor = stickColor
        sticks.strokeColor = stickStrokeColor
        sticks.bind = self
        board.addChild(sticks)
        
        return board
    }
    
    override func onBeginContact(board: SKNode, ball: Ball, contact: SKPhysicsContact, game: GameDelegate) {
        
        if board.physicsBody!.categoryBitMask == self.stickCollideMask {
            game.stopGame()
        }
    }
    override func playCollideSound(fromFloor: Int, toFloor: Int) {
        
    }
    
    private func makeSticks(boardAvaliableWidth: CGFloat)-> SKShapeNode {
        
        let stickCount = Int(floor(boardAvaliableWidth / CGFloat(stickWidth)))
        
        var drawX = CGFloat(0)
        let sticksPath = CGPathCreateMutable()
        CGPathMoveToPoint(sticksPath, nil, drawX, CGFloat(0))
        for _ in 0 ..< stickCount {
            drawX += CGFloat(stickWidth / 2)
            CGPathAddLineToPoint(sticksPath, nil, drawX, CGFloat(stickHeight))
            drawX += CGFloat(stickWidth / 2)
            CGPathAddLineToPoint(sticksPath, nil, drawX, CGFloat(0))
        }
        CGPathCloseSubpath(sticksPath)
        
        let sticks = SKShapeNode(path: sticksPath)
        sticks.physicsBody = SKPhysicsBody(rectangleOfSize: sticks.frame.size, center: CGPoint(x: sticks.frame.width / 2, y: sticks.frame.height / 2))
        sticks.physicsBody!.categoryBitMask = stickCollideMask
        sticks.physicsBody!.dynamic = false
        
        return sticks
    }
    
}