//
//  GameScene.swift
//  BallDown
//
//  Copyright (c) 2015 ones. All rights reserved.
//

import SpriteKit
import AVFoundation

class Layout {
    
    static let h1 = CGFloat(400)
    static let h2 = CGFloat(300)
    static let h3 = CGFloat(200)
    static let h4 = CGFloat(100)
    static let h5 = CGFloat(50)
    static let h6 = CGFloat(30)
    static let fontName = "Helvetica"
    static let padding = CGFloat(100)
    static let radius = CGFloat(65)
}

protocol GameDelegate {
    
    var start: Bool {get}
    var score: Int {get}
    var accelerate: CGFloat {get}
    
    func startGame()
    func stopGame()
}

class GameScene: SKScene, GameDelegate, SKPhysicsContactDelegate {
    
    // game
    var start = false
    var disableStart = false
    
    // node name
    static let NAME_CLOUD = "cloud"
    
    // action name
    static let ACTION_BOARD_MOVE_TO_TOP_THEN_REMOVE = "board.moveToTopThenRemove"
    static let ACTION_CLOUD_MOVE_TO_TOP_THEN_REMOVE = "cloud.moveToTopThenRemove"
    
    // accelerate
    let accelerateScoreInterval = 3
    let accelerateInterval = CGFloat(0.2)
    var accelerate = CGFloat(1.0)
    
    // gravity
    let gravity = CGFloat(-9.8)
    
    // ball
    var ball: Ball!
    let ballSpeedX = CGFloat(500)
    
    // board
    let boards = Boards.make(CollideType.BoardStart.rawValue)
    var lastBoard: SKNode?
    var boardSpeedY: CGFloat { get { return CGFloat(160) * accelerate }}
    let boardDistanceY = CGFloat(300)
    let boardYDistanceHide = CGFloat(30)
    
    // cloud
    var lastCloud: SKNode!
    var cloudSpeedY: CGFloat { get { return CGFloat(30) * accelerate }}
    let cloudDistanceY = CGFloat(250)
    let cloudYDistanceHide = CGFloat(50)
    
    // current score
    var currentScore: NumberNode!
    var score: Int { get { return self.currentScore.intValue }} 
    let currentScoreColor = SKColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
    let currentScoreAfterBestColor = SKColor(hue: CGFloat(0) / 360.0, saturation: 0.6, brightness: 0.9, alpha: 1)
    
    // best score
    var bestScore: NumberNode!
    var bestScoreTopDistance = CGFloat(260)
    let bestScoreToggleDuration = NSTimeInterval(0.3)
    
    // new label
    var newLabel: SKLabelNode!
    
    // play button
    var playBtn: SKShapeNode!
    let playBtnToggleDuration = NSTimeInterval(0.2)
    
    // rank button
    var rankBtn: SKShapeNode!
    let bottomBtnToggleDuration = NSTimeInterval(0.3)
    var bottomLineHeight = CGFloat(200)
    let bottomBetween = CGFloat(300)
    
    // share button group
    var shareButtonGroup: ShareButtonGroup!
    
    // guide
    var guide: SKNode?
    let guideCount = 5
    let guideBestScoreLimit = 25
    
    // ad
    let adIntervalCount = 5
    
    // store alert
    let storeAlertAtCount = 30
    
    override func didMoveToView(view: SKView) {
        
        // physics world
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        self.backgroundColor = SKColor(hue: 209 / 360.0, saturation: 0.51, brightness: 0.75, alpha: 1)
        
        // clouds
        var cloudYPosition = self.frame.height - cloudYDistanceHide
        while cloudYPosition > 0 {
            
            let cloud = newCloud()
            cloud.position.y = cloudYPosition
            self.addChild(cloud)
            self.lastCloud = cloud
            
            cloudYPosition -= cloudDistanceY
        }
        
        // current score
        currentScore = NumberNode()
        currentScore.horizontalAlignmentMode = .Right
        currentScore.fontName = Layout.fontName
        currentScore.fontSize = Layout.h4
        currentScore.fontColor = currentScoreColor
        currentScore.position.x = self.frame.width - Layout.padding
        currentScore.position.y = self.frame.height - Layout.padding - currentScore.fontSize / 2
        currentScore.intValue = 0
        self.addChild(currentScore)
        
        // best score
        bestScore = NumberNode()
        bestScore.horizontalAlignmentMode = .Right
        bestScore.fontName = Layout.fontName
        bestScore.fontSize = Layout.h4
        bestScore.fontColor = SKColor.yellowColor()
        bestScore.position.x = self.frame.width - Layout.padding
        bestScore.position.y = self.frame.height - bestScoreTopDistance
        bestScore.intValue = UserDefaults.share().bestScore
        self.addChild(bestScore)
        
        // new label
        newLabel = SKLabelNode()
        newLabel.position.x = CGFloat(-bestScore.frame.width)
        newLabel.position.y = CGFloat(30)
        newLabel.horizontalAlignmentMode = .Right
        newLabel.fontSize = Layout.h6
        newLabel.fontName = Layout.fontName
        newLabel.fontColor = SKColor.redColor()
        newLabel.zRotation = CGFloat(M_PI) / -180 * 20
        newLabel.text = "New"
        newLabel.hidden = true
        bestScore.addChild(newLabel)

        
        // rank medals podium
        let podiumWidth = Layout.radius * 1.2
        let eachPodiumWeight = CGFloat(3)
        let eachPodiumWidth = (CGFloat(1) - (CGFloat(2)/(eachPodiumWeight * CGFloat(3) + CGFloat(2 * 1)))) * podiumWidth / 3
        let maxPodiumHeigh = Layout.radius * 1
        let eachSpace = eachPodiumWidth / eachPodiumWeight
        let podiumPath = CGPathCreateMutable()
        CGPathAddRect(podiumPath, nil, CGRect(x: 0, y: 0, width: eachPodiumWidth, height: maxPodiumHeigh * 0.8))
        CGPathAddRect(podiumPath, nil, CGRect(x: eachPodiumWidth + eachSpace, y: 0, width: eachPodiumWidth, height: maxPodiumHeigh))
        CGPathAddRect(podiumPath, nil, CGRect(x: eachPodiumWidth * 2 + eachSpace * 2, y: 0, width: eachPodiumWidth, height: maxPodiumHeigh * 0.6))
        
        let medalsPodium = SKShapeNode(path: podiumPath, centered: true)
        medalsPodium.name = "rank.medalsPodium"
        medalsPodium.fillColor = SKColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
        medalsPodium.strokeColor = SKColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
        
        // rank button
        rankBtn = CircleButton.shape(medalsPodium, onTapped: {node in
            println("on button rank tapped")
            GameCenter.share().showLeaderboard(AppDelegate.gameController!)
        })
        rankBtn.position.x = Layout.padding + Layout.radius
        rankBtn.position.y = bottomLineHeight
        rankBtn.zPosition = 100
        
        self.addChild(rankBtn)
        
        // share button group
        shareButtonGroup = ShareButtonGroup.make(self)
        shareButtonGroup.position.x = self.frame.width - Layout.padding - Layout.radius
        shareButtonGroup.position.y = bottomLineHeight
        shareButtonGroup.zPosition = 100
        
        self.addChild(shareButtonGroup)
        
        // play button
        playBtn = SKShapeNode(circleOfRadius: 120)
        playBtn.position.x = CGRectGetMidX(self.frame)
        playBtn.position.y = CGRectGetMidY(self.frame)
        playBtn.lineWidth = CGFloat(3.0)
        playBtn.name = "btn.play"
        playBtn.zPosition = 100
        
        // play triangle
        let triangleRadius = CGFloat(85)
        let triangleRightX = triangleRadius
        let triangleLeftX = CGFloat(-triangleRadius / 2)
        let triangleLefty = CGFloat(triangleRadius * 1.73 / 2)
        let trianglePath = CGPathCreateMutable()
        CGPathMoveToPoint(trianglePath, nil, triangleRightX, CGFloat(0))
        CGPathAddLineToPoint(trianglePath, nil, triangleLeftX, triangleLefty)
        CGPathAddLineToPoint(trianglePath, nil, triangleLeftX, -triangleLefty)
        CGPathCloseSubpath(trianglePath)
        
        let triangle = SKShapeNode(path: trianglePath)
        triangle.fillColor = SKColor.whiteColor()
        playBtn.addChild(triangle)
        
        self.addChild(playBtn)
        
        // scene
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody!.categoryBitMask = CollideType.Scene.toMask()
        self.physicsBody!.dynamic = false
        self.physicsBody!.friction = 0
        
        // ceil
        let ceil = SKShapeNode(rectOfSize: CGSize(width: self.frame.width, height: 2))
        ceil.position.x = CGRectGetMidX(self.frame)
        ceil.position.y = self.frame.height - CGRectGetMidY(ceil.frame)
        ceil.physicsBody = SKPhysicsBody(rectangleOfSize: ceil.frame.size)
        ceil.physicsBody!.categoryBitMask = CollideType.Ceil.toMask()
        ceil.physicsBody!.dynamic = false
        ceil.alpha = 0
        self.addChild(ceil)
        
        // floor
        let floor = SKShapeNode(rectOfSize: CGSize(width: self.frame.width, height: 2))
        floor.position.x = CGRectGetMidX(self.frame)
        floor.position.y = CGRectGetMidY(floor.frame)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: floor.frame.size)
        floor.physicsBody!.categoryBitMask = CollideType.Floor.toMask()
        floor.physicsBody!.dynamic = false
        floor.alpha = 0
        self.addChild(floor)
        
        // ball
        ball = Ball.make()
        ball.position.x = CGRectGetMidX(self.frame)
        ball.position.y = CGRectGetMidY(self.frame)
        ball.physicsBody!.categoryBitMask = CollideType.Ball.toMask()
        ball.physicsBody!.collisionBitMask = CollideType.toMask([.Scene, .Ceil, .Floor]) | boards.usedCollideMasks
        ball.physicsBody!.contactTestBitMask = CollideType.toMask([.Scene, .Ceil, .Floor]) | boards.usedCollideMasks
        ball.hidden = true
        self.addChild(ball)
        
        // av
        Av.share()
        
        // game center
        GameCenter.share().auth(nil, showLogin: false)
        
        // ad
        Ad.share()

    }
    override func update(currentTime: CFTimeInterval) {
        
        if !start {
            return
        }
        
        // accelerate
        self.physicsWorld.gravity.dy = self.gravity * accelerate
        ball.physicsBody!.velocity.dx = ball.xSpeed * (log10(accelerate) + 1)
        
        // make new cloud
        if lastCloud.position.y + cloudYDistanceHide >= self.cloudDistanceY {
            let cloud = self.newCloud()
            self.addChild(cloud)
            self.cloudRunMoveAction(cloud)
            
            lastCloud = cloud
        }
        
        if let lastBoard = self.lastBoard {
            
            
            // make new board
            if lastBoard.position.y + boardYDistanceHide >= self.boardDistanceY {
                
                self.currentScore.intValue++
                
                let newBoard = self.newBoard(false)
                self.addChild(newBoard)
                self.lastBoard = newBoard
                
                if self.currentScore.intValue > self.bestScore.intValue {
                    self.currentScore.fontColor = self.currentScoreAfterBestColor
                }
                
                updateCloudsAndBoardsSpeedY()
            }
        }
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent?) {
        
        // do nothing if ad is showing
        if Ad.share().showing {
            return
        }
        
        let touch = touches.first as! UITouch
        let touchedLocation = touch.locationInNode(self)
        
        // change the speedXFirst of the ball if it starts
        if start {
            
            // start move
            let moveRight = touchedLocation.x > CGRectGetMidX(self.frame)
            let speedX = moveRight ? ballSpeedX : -ballSpeedX
            ball.speedXFirst = speedX
        }
        
        // start game if it stops
        else {
            startGame()
        }
        
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent?) {
        
        if start {
            
            // stop move
            ball.speedXFirst = 0
        }
    }
    func didBeginContact(contact: SKPhysicsContact) {
        
        let bitMaskAAndB = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        let ballAndBoardMask = CollideType.Ball.toMask() | boards.usedCollideMasks
        
        // ball and board, handle it by board delegate
        if bitMaskAAndB | ballAndBoardMask == ballAndBoardMask {
            
            let boardNode: SKNode! = contact.bodyA.categoryBitMask == CollideType.Ball.toMask() ? contact.bodyB.node : contact.bodyA.node
            let board = boardNode.bind as! BoardDelegate
            board.didBeginContact(boardNode, ball: ball, contact: contact, game: self)
        }
        
        // ball and ceil => stop game
        else if bitMaskAAndB == CollideType.toMask([.Ball, .Ceil]) {
            stopGame()
        }
            
        // ball and floor => stop game
        else if bitMaskAAndB == CollideType.toMask([.Ball, .Floor]) {
            stopGame()
        }
    }
    func didEndContact(contact: SKPhysicsContact) {
        
        let ballAndBoardMask = CollideType.Ball.toMask() | boards.usedCollideMasks
        
        // ball and board, handle it by board delegate
        if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask | ballAndBoardMask == ballAndBoardMask {
            
            let boardNode: SKNode! = contact.bodyA.categoryBitMask == CollideType.Ball.toMask() ? contact.bodyB.node : contact.bodyA.node
            let board = boardNode.bind as! BoardDelegate
            board.didEndContact(boardNode, ball: ball, contact: contact, game: self)
        }
        
    }
    func startGame() {
        
        if start || disableStart {
            return
        }
        
        // increase played count
        let playedCount = UserDefaults.share().playedCount + 1
        UserDefaults.share().playedCount = playedCount
        
        println("start game \(playedCount)")
        
        // hide play button
        playBtn.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(playBtnToggleDuration),
            SKAction.runBlock({
                self.playBtn.hidden = true
            })
        ]), withKey: "hide")
        playBtn.runAction(SKAction.sequence([
            SKAction.scaleTo(1.03, duration: playBtnToggleDuration / 2),
            SKAction.scaleTo(1, duration: playBtnToggleDuration / 2)
        ]), withKey: "scaleChange")
        
        // hide best score and new label
        bestScore.runAction(SKAction.sequence([
            SKAction.moveToY(self.frame.height + bestScore.frame.height, duration: self.bestScoreToggleDuration),
        ]))
        bestScore.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(self.bestScoreToggleDuration),
            SKAction.runBlock({
                self.bestScore.hidden = true
            })
        ]))
        
        newLabel.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(self.bestScoreToggleDuration),
            SKAction.runBlock({
                self.newLabel.hidden = true
            })
        ]))
        
        // hide rank
        self.hideBottomBtn(rankBtn)
        
        // hide share button group
        shareButtonGroup.close()
        self.hideBottomBtn(shareButtonGroup)
        
        // reset ball
        self.ball.hidden = false
        self.ball.position.x = CGRectGetMidX(self.frame)
        self.ball.position.y = CGRectGetMidY(self.frame)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: self.gravity)
        
        // reset current score
        self.currentScore.intValue = self.currentScore.intValue / 2
        self.currentScore.fontColor = self.currentScoreColor
        
        // reset accelerate
        self.accelerate = CGFloat(1.0)
        
        for child in self.children {
            
            let childNode = child as! SKNode
            
            // remove old boards
            if let board = childNode.bind as? BoardDelegate {
                
                board.onDestroy()
                childNode.removeFromParent()
            }
            
            // recover old clouds move action
            if (childNode.name == GameScene.NAME_CLOUD) {
                cloudRunMoveAction(childNode)
            }
        }
        
        // check guide
        if playedCount <= guideCount && bestScore.intValue <= guideBestScoreLimit {
            guide?.removeFromParent()
            guide = newGuide()
            self.addChild(guide!)
        }
        
        // reset board
        let firstBoard = newBoard(true)
        firstBoard.position.x = self.frame.width / 2
        self.addChild(firstBoard)
        self.lastBoard = firstBoard
        
        // update clouds and boards sppeeY
        updateCloudsAndBoardsSpeedY()
        
        // start game
        start = true
        
        // play the tap button sound
        Av.share().tapButton.play()
    }
    
    func stopGame() {
        
        if !start {
            return
        }
        
        println("stop game")
        
        // remove guide
        guide?.removeFromParent()
        guide = nil
        
        // show play button
        playBtn.runAction(SKAction.sequence([
            SKAction.runBlock({
                self.playBtn.alpha = 0
                self.playBtn.hidden = false
            }),
            SKAction.fadeInWithDuration(playBtnToggleDuration)
        ]), withKey: "show")
        
        // show best score
        bestScore.runAction(SKAction.sequence([
            SKAction.runBlock({
                self.bestScore.hidden = false
            }),
            SKAction.moveToY(self.frame.height - self.bestScoreTopDistance, duration: self.bestScoreToggleDuration)
        ]))
        bestScore.runAction(SKAction.sequence([
            SKAction.fadeInWithDuration(self.bestScoreToggleDuration)
        ]))
        
        // add best score
        if (currentScore.intValue > bestScore.intValue) {
            
            bestScore.runAction(SKAction.sequence([
                SKAction.waitForDuration(self.bestScoreToggleDuration + NSTimeInterval(0.5)),
                SKAction.runBlock({
                    self.bestScore.addTo(self.currentScore.intValue, complete: {
                        self.newLabel.runAction(SKAction.sequence([
                            SKAction.runBlock({
                                self.newLabel.position.x = CGFloat(-self.bestScore.frame.width)
                                self.newLabel.hidden = false
                            }),
                            SKAction.fadeInWithDuration(NSTimeInterval(0.3))
                        ]))
                    })
                })
            ]))
            
            // store in local
            UserDefaults.share().bestScore = currentScore.intValue
        }
        
        let hiddenBottomBtn = !World.isConnected()
        
        // show bottom button
        showBottomBtn(rankBtn, hidden: hiddenBottomBtn)
        
        // show bottom buttom
        showBottomBtn(shareButtonGroup, hidden: hiddenBottomBtn)
        
        // freeze ball
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        ball.freezeX()
        ball.physicsBody!.velocity.dx = 0
        ball.physicsBody!.velocity.dy = 0
        
        // remove move actions
        for child in self.children {
            
            // remove board move action
            if child.actionForKey(GameScene.ACTION_BOARD_MOVE_TO_TOP_THEN_REMOVE) != nil {
                child.removeActionForKey(GameScene.ACTION_BOARD_MOVE_TO_TOP_THEN_REMOVE)
            }
            
            // remove cloud move action
            if child.actionForKey(GameScene.ACTION_CLOUD_MOVE_TO_TOP_THEN_REMOVE) != nil {
                child.removeActionForKey(GameScene.ACTION_CLOUD_MOVE_TO_TOP_THEN_REMOVE)
            }
        }
        
        disableStart = true
        self.runAction(SKAction.waitForDuration(NSTimeInterval(0.5)), completion: {
            self.disableStart = false
        })
        
        start = false
        
        let playedCount = UserDefaults.share().playedCount
        
        // show the store review if needed
        let lastStoreAlertAtCount = UserDefaults.share().lastStoreAlertAtCount
        if lastStoreAlertAtCount <= 0 && playedCount >= self.storeAlertAtCount {
            
            // show store alert view to review
            Store.share().tryShow(playedCount)
        }
        
        // show an ad if needed
        else {
            
            // ad
            let lastAdAdCount = UserDefaults.share().lastAdAtCount
            if playedCount - lastAdAdCount >= adIntervalCount {
                let showing = Ad.share().show()
                if showing {
                    UserDefaults.share().lastAdAtCount = playedCount
                }
            }
        }
        
        // gamecenter, update best score if needed
        GameCenter.share().tick()
        
        // play game over sound
        Av.share().gameOver.play()
    }
    private func updateCloudsAndBoardsSpeedY() {
        
        // accelerate
        let needAccelerate = CGFloat((self.currentScore.intValue / self.accelerateScoreInterval)) * self.accelerateInterval + CGFloat(1.0)
        if needAccelerate != self.accelerate {
            
            self.accelerate = needAccelerate
            println("accelerate to \(self.accelerate)")
            
            for child in self.children as! [SKNode] {
                
                let childNode = child
                
                // update old boards speedY
                if childNode.bind != nil {
                    self.boardRunMoveAction(childNode)
                }
                
                // update old clouds speedY
                if childNode.name == GameScene.NAME_CLOUD {
                    self.cloudRunMoveAction(childNode)
                }
            }
        }
    }
    private func hideBottomBtn(bottomBtn: SKNode) {
    
        let leaveToPositionY = -(Layout.radius + 5)
        
        bottomBtn.runAction(SKAction.sequence([
                SKAction.moveToY(leaveToPositionY, duration: bottomBtnToggleDuration),
                SKAction.runBlock({
                    bottomBtn.hidden = true
                })
            ]), withKey: "hideBottomBtn")
        bottomBtn.runAction(SKAction.fadeOutWithDuration(bottomBtnToggleDuration))
    }
    private func showBottomBtn(bottomBtn: SKNode, hidden: Bool) {
        
        bottomBtn.runAction(SKAction.sequence([
            SKAction.runBlock({
                bottomBtn.alpha = 0
                bottomBtn.hidden = hidden
            }),
            SKAction.moveToY(bottomLineHeight, duration: bottomBtnToggleDuration)
        ]), withKey: "showBottomBtn")
        bottomBtn.runAction(SKAction.fadeInWithDuration(bottomBtnToggleDuration))
    }
    private func boardRunMoveAction(boardNode: SKNode) {
        
        boardNode.removeActionForKey(GameScene.ACTION_BOARD_MOVE_TO_TOP_THEN_REMOVE)
        boardNode.runAction(SKAction.sequence([
            SKAction.moveToY(self.frame.height + boardYDistanceHide, duration: NSTimeInterval((self.frame.height + boardYDistanceHide - boardNode.position.y) / self.boardSpeedY)),
            SKAction.runBlock({[unowned boardNode] in
                if let board = boardNode.bind as? BoardDelegate {
                    board.onDestroy()
                }
            }),
            SKAction.removeFromParent()
        ]), withKey: GameScene.ACTION_BOARD_MOVE_TO_TOP_THEN_REMOVE)
    }
    private func cloudRunMoveAction(cloud: SKNode) {
        
        cloud.removeActionForKey(GameScene.ACTION_CLOUD_MOVE_TO_TOP_THEN_REMOVE)
        cloud.runAction(SKAction.sequence([
            SKAction.moveToY(self.frame.height + cloud.frame.height, duration: NSTimeInterval((self.frame.height + cloud.frame.height - cloud.position.y) / self.cloudSpeedY)),
            SKAction.removeFromParent()
            ]), withKey: GameScene.ACTION_CLOUD_MOVE_TO_TOP_THEN_REMOVE)
    }
    private func newBoard(isFirst: Bool)-> SKNode {
        
        let floorNumber = currentScore.intValue
        let board = isFirst ? boards.newNormalBoard(floorNumber) : boards.newBoard(floorNumber)
        let boardNode = board.node
        
        boardNode.position.x =  CGFloat(arc4random_uniform(UInt32(CGFloat(self.frame.width - Boards.width)))) + Boards.width / 2
        boardNode.position.y = -self.boardYDistanceHide
        self.boardRunMoveAction(boardNode)
        
        return boardNode
    }
    private func newCloud()-> SKNode {
        
        var cloudPath: CGMutablePath!
        let cloudPathType = arc4random_uniform(3)
        switch cloudPathType {
        case 0:
            cloudPath = CGPathCreateMutable()
            CGPathMoveToPoint(cloudPath, nil, 0, 0)
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(-50), CGFloat(50), CGFloat(30), CGFloat(110), CGFloat(80), CGFloat(100))
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(120), CGFloat(170), CGFloat(180), CGFloat(170), CGFloat(220), CGFloat(100))
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(270), CGFloat(110), CGFloat(350), CGFloat(50), CGFloat(300), CGFloat(0))
            CGPathCloseSubpath(cloudPath)
        case 1:
            cloudPath = CGPathCreateMutable()
            CGPathMoveToPoint(cloudPath, nil, 0, 0)
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(-80), CGFloat(50), CGFloat(-20), CGFloat(100), CGFloat(30), CGFloat(100))
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(70), CGFloat(170), CGFloat(120), CGFloat(170), CGFloat(170), CGFloat(100))
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(190), CGFloat(80), CGFloat(200), CGFloat(110), CGFloat(230), CGFloat(70))
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(280), CGFloat(80), CGFloat(310), CGFloat(40), CGFloat(260), CGFloat(0))
            CGPathCloseSubpath(cloudPath)
        case 2:
            cloudPath = CGPathCreateMutable()
            CGPathMoveToPoint(cloudPath, nil, 0, 0)
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(80), CGFloat(50), CGFloat(20), CGFloat(100), CGFloat(-30), CGFloat(100))
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(-70), CGFloat(170), CGFloat(-120), CGFloat(170), CGFloat(-170), CGFloat(100))
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(-190), CGFloat(80), CGFloat(-200), CGFloat(110), CGFloat(-230), CGFloat(70))
            CGPathAddCurveToPoint(cloudPath, nil, CGFloat(-280), CGFloat(80), CGFloat(-310), CGFloat(40), CGFloat(-260), CGFloat(0))
            CGPathCloseSubpath(cloudPath)
        default:
            fatalError("cloud type: \(cloudPathType) don`t exist")
        }
        
        let cloud = SKShapeNode(path: cloudPath, centered: true)
        cloud.name = GameScene.NAME_CLOUD
        cloud.xScale = CGFloat(arc4random_uniform(2)) / CGFloat(10) + CGFloat(0.7)
        cloud.yScale = CGFloat(arc4random_uniform(2)) / CGFloat(10) + CGFloat(0.7)
        cloud.fillColor = SKColor(white: 1, alpha: CGFloat(arc4random_uniform(3)) / CGFloat(10) + CGFloat(0.3))
        cloud.strokeColor = cloud.fillColor
        
        cloud.position.x = CGFloat(arc4random_uniform(UInt32(self.frame.width)))
        cloud.position.y = -cloudYDistanceHide
        
        return cloud
    }
    private func newGuide()-> SKNode {
        
        let guide = SKNode()
        guide.position.y = 350
        
        buildGuidePart(guide, isLeft: true)
        buildGuidePart(guide, isLeft: false)
        
        guide.runAction(SKAction.sequence([
            SKAction.waitForDuration(3),
            SKAction.fadeOutWithDuration(1),
            SKAction.removeFromParent()
        ]))
        
        return guide
    }
    private func buildGuidePart(guide: SKNode, isLeft: Bool) {
        
        let radius = 100
        let distanceToMiddle = 120
        let guidePart = SKShapeNode(circleOfRadius: CGFloat(radius))
        guidePart.position.x = isLeft ? self.frame.width / 2 - (CGFloat(radius) + CGFloat(distanceToMiddle)) : self.frame.width / 2 + (CGFloat(radius) + CGFloat(distanceToMiddle))
        guidePart.lineWidth = 2.0
        guidePart.strokeColor = SKColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
        guide.addChild(guidePart)
        
        // circle action
        guidePart.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.scaleTo(1.2, duration: 1),
            SKAction.scaleTo(1, duration: 0.2)
        ])))
        
        let icon = SKLabelNode()
        icon.fontName = FA.FONT
        icon.text = isLeft ? FA.hand_o_left : FA.hand_o_right
        icon.fontSize = 70
        icon.horizontalAlignmentMode = .Center
        icon.position.x = guidePart.position.x
        icon.position.y = guidePart.position.y - 20
        guide.addChild(icon)
        
        // icon action
        icon.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(0.5),
            SKAction.moveBy(CGVector(dx: 0, dy: -20), duration: 0.3),
            SKAction.waitForDuration(0.1),
            SKAction.moveBy(CGVector(dx: 0, dy: 20), duration: 0.3)
        ])))
    }
}
