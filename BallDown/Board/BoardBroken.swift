//
//  BoardBroken.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

class BoardBroken: BoardAbstract {
    
    static let BOARD_LEFT_NAME = "BrokenBoard.leftBoard"
    static let BOARD_RIGHT_NAME = "BrokenBoard.rightBoard"
    
    let gapWidth = CGFloat(10)
    let leftBoardWidth = Boards.width * 0.6
    let actionDuration = NSTimeInterval(1)
    let fillColor = SKColor(hue: CGFloat(30) / 360.0, saturation: 0.2, brightness: 0.9, alpha: 1)
    let strokeColor = SKColor(hue: CGFloat(30) / 360.0, saturation: 0.2, brightness: 0.7, alpha: 1)
    
    var leftBoardCollideMask: UInt32!
    var rightBoardCollideMask: UInt32!
    
    weak var leftBoard: SKShapeNode!
    weak var rightBoard: SKShapeNode!
   
    override func newNode(boardTemplate: BoardTemplate, boardSize: CGSize) -> SKNode {
        
        leftBoardCollideMask = boardTemplate.collideMaskFirst
        rightBoardCollideMask = boardTemplate.collideMaskSecond
        
        let boardWidth = boardSize.width
        let boardHeigh = boardSize.height / 2
        let radius = boardHeigh / 2
        let board = SKNode()
        
        let leftPath = CGPathCreateMutable()
        CGPathAddArc(leftPath, nil, CGFloat(0), CGFloat(0), radius, CGFloat(-M_PI_2), CGFloat(M_PI_2), true)
        CGPathAddLineToPoint(leftPath, nil, leftBoardWidth - radius - gapWidth, radius)
        CGPathAddLineToPoint(leftPath, nil, leftBoardWidth - radius, -radius)
        CGPathCloseSubpath(leftPath)
        
        let leftBoard = SKShapeNode(path: leftPath, centered: false)
        leftBoard.name = BoardBroken.BOARD_LEFT_NAME
        leftBoard.physicsBody = SKPhysicsBody(rectangleOfSize: leftBoard.frame.size, center: CGPoint(x: (leftBoardWidth / 2 - radius), y: CGFloat(0)))
        leftBoard.physicsBody!.categoryBitMask = leftBoardCollideMask
        leftBoard.physicsBody!.dynamic = false
        leftBoard.position.x = -(boardWidth / 2 - radius)
        leftBoard.userData = NSMutableDictionary()
        leftBoard.userData!.setValue(self, forKey: Boards.DATA_BOARD_NAME)
        leftBoard.fillColor = fillColor
        leftBoard.strokeColor = strokeColor
        board.addChild(leftBoard)
        self.leftBoard = leftBoard
        self.leftBoard.bind = self
        
        let rightBoardWidth = boardWidth - leftBoardWidth
        let rightPath = CGPathCreateMutable()
        CGPathAddArc(rightPath, nil, CGFloat(0), CGFloat(0), radius, CGFloat(M_PI_2), CGFloat(-M_PI_2), true)
        CGPathAddLineToPoint(rightPath, nil, -(rightBoardWidth - radius - gapWidth), -radius)
        CGPathAddLineToPoint(rightPath, nil, -(rightBoardWidth - radius), radius)
        CGPathCloseSubpath(rightPath)
        
        let rightBoard = SKShapeNode(path: rightPath, centered: false)
        rightBoard.name = BoardBroken.BOARD_RIGHT_NAME
        rightBoard.physicsBody = SKPhysicsBody(rectangleOfSize: rightBoard.frame.size, center: CGPoint(x: -(rightBoardWidth / 2 - radius), y: CGFloat(0)))
        rightBoard.physicsBody!.categoryBitMask = rightBoardCollideMask
        rightBoard.physicsBody!.dynamic = false
        rightBoard.position.x = boardWidth / 2 - radius
        rightBoard.userData = NSMutableDictionary()
        rightBoard.userData!.setValue(self, forKey: Boards.DATA_BOARD_NAME)
        rightBoard.fillColor = fillColor
        rightBoard.strokeColor = strokeColor
        board.addChild(rightBoard)
        self.rightBoard = rightBoard
        self.rightBoard.bind = self
        
        return board
    }
    
    override func onBeginContact(board: SKNode, ball: Ball, contact: SKPhysicsContact, game: GameDelegate) {
        
        if leftBoard.actionForKey("rotate") == nil && rightBoard.actionForKey("rotate") == nil {
            makeActions(leftBoard, isLeft: true)
            makeActions(rightBoard, isLeft: false)
        }
    }
    
    private func makeActions(board: SKNode, isLeft: Bool) {
        board.runAction(SKAction.rotateByAngle(CGFloat(isLeft ? -M_PI_2 : M_PI_2), duration: actionDuration), withKey: "rotate")
        board.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(actionDuration),
            SKAction.removeFromParent()
        ]))
    }

}
