//
//  Boards.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

protocol BoardDelegate {
    
    var floorNumber: Int! {get}
    var node: SKNode! {get}
    
    func onCreate(boardTemplate: BoardTemplate, floorNumber: Int)
    func onDestroy()
    func didBeginContact(board: SKNode, ball: Ball, contact: SKPhysicsContact, game: GameDelegate)
    func didEndContact(board: SKNode, ball: Ball, contact: SKPhysicsContact, game: GameDelegate)
}

class BoardTemplate {
    
    let weight: Int
    let collideCount: Int
    let boardMaker: ()-> BoardDelegate
    
    var startCollide: Int!
    var collideMaskFirst: UInt32 {
        get {
            if collideCount < 1 {
                fatalError("board collideCount does have first bit mask")
            }
            return UInt32(1 << (startCollide))
        }
    }
    var collideMaskSecond: UInt32 {
        get {
            if collideCount < 2 {
                fatalError("board collideCount does have seconde bit mask")
            }
            return UInt32(1 << (startCollide + 1))
        }
    }
    
    init(weight: Int, collideCount: Int, boardMaker: ()-> BoardDelegate) {
        self.weight = weight
        self.collideCount = collideCount
        self.boardMaker = boardMaker
    }
    
    func onCreate(startCollide: Int) {
        self.startCollide = startCollide
    }
    
    func newBoard(floorNumber: Int)-> BoardDelegate {
        let board = boardMaker()
        board.onCreate(self, floorNumber: floorNumber)
        return board
    }
    
}

class Boards {
    

    static let DATA_BOARD_NAME = "board"
    
    static let normalBoardColor = SKColor(hue: CGFloat(35) / 360.0, saturation: 0.75, brightness: 0.9, alpha: 1)
    static let normalBoardStrokeColor = SKColor(hue: CGFloat(35) / 360.0, saturation: 0.75, brightness: 0.7, alpha: 1)
    
    static let radius = CGFloat(10)
    static let width = CGFloat(200)
    static let height = CGFloat(25)
    
    let collideIndexStart: Int
    var usedCollideCount = 0
    
    var usedCollideMasks: UInt32 {
        get {
            var collideMasks: UInt32 = 0
            var offset = self.collideIndexStart
            for _ in 0..<self.usedCollideCount {
                collideMasks |= UInt32(1 << offset++)
            }
            return collideMasks
        }
    }
    
    let boardTemplates = [
        BoardTemplate(weight: 30, collideCount: 1, boardMaker: {BoardNormal()}),
        BoardTemplate(weight: 10, collideCount: 2, boardMaker: {BoardSticks()}),
        BoardTemplate(weight: 10, collideCount: 1, boardMaker: {BoardScroll()}),
        BoardTemplate(weight:  5, collideCount: 2, boardMaker: {BoardSpring()}),
        BoardTemplate(weight:  5, collideCount: 2, boardMaker: {BoardBroken()})
    ]
    
    private init(collideIndexStart: Int) {
        
        self.collideIndexStart = collideIndexStart
    }
    private func onCreate() {
        
        usedCollideCount = 0
        for boardTemplate in self.boardTemplates {
            boardTemplate.onCreate(collideIndexStart + usedCollideCount)
            usedCollideCount += boardTemplate.collideCount
        }
    }
    
    static func make(collideIndexStart: Int)-> Boards {
        
        let boards = Boards(collideIndexStart: collideIndexStart)
        boards.onCreate()
        return boards
    }
    
    func newBoard(floorNumber: Int)-> BoardDelegate {
        
        var allWeights = 0
        for boardTemplate in boardTemplates {
            allWeights += boardTemplate.weight
        }
        
        let randomWeight = Int(arc4random_uniform(UInt32(allWeights)))
        var testRandomWeight = 0
        var boardTemplateGiven: BoardTemplate!
        for boardTemplate in boardTemplates {
            testRandomWeight += boardTemplate.weight
            if randomWeight < testRandomWeight {
                boardTemplateGiven = boardTemplate
                break
            }
        }
        
        return boardTemplateGiven.newBoard(floorNumber)
    }
    func newNormalBoard(floorNumber: Int)-> BoardDelegate {
        let boardTemplateNormal = boardTemplates[0]
        return boardTemplateNormal.newBoard(floorNumber)
    }
}



