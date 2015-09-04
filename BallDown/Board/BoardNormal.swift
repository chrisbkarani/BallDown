//
//  BoardNormal.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

class BoardNormal: BoardAbstract {
    
    var boardCollideMask: UInt32!
    
    override func newNode(boardTemplate: BoardTemplate, boardSize: CGSize)-> SKNode {
        
        boardCollideMask = boardTemplate.collideMaskFirst

        let board = SKShapeNode(rectOfSize: boardSize, cornerRadius: Boards.radius)
        board.name = "BoardNormal"
        board.userData = NSMutableDictionary()
        board.userData!.setValue(self, forKey: Boards.DATA_BOARD_NAME)
        board.physicsBody = SKPhysicsBody(rectangleOfSize: board.frame.size)
        board.physicsBody!.categoryBitMask = boardCollideMask
        board.physicsBody!.dynamic = false
        board.position.x = board.frame.width / 2
        
        board.fillColor = Boards.normalBoardColor
        board.strokeColor = Boards.normalBoardStrokeColor
        
        return board
    }
    
}

