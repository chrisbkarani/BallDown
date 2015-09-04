//
//  CircleButton.swift
//  BallDown
//
//  Copyright (c) 2015 ones. All rights reserved.
//

import Foundation
import SpriteKit

class CircleButton: SKShapeNode {
    
    static let radius = CGFloat(65)
    static let outlineLineWidth = CGFloat(2)
    static let strokeColorNormal = SKColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
    static let strokeColorTapped = SKColor(hue: 0, saturation: 0, brightness: 0.68, alpha: 0.4)
    static let fillColorNormal = SKColor(hue: 0, saturation: 0, brightness: 1, alpha: 0)
    static let fillColorTapped = SKColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 0.4)
    static let contentColorNormal = SKColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
    static let contentColorTapped = SKColor(hue: 0, saturation: 0, brightness: 1, alpha: 0)
    
    // state
    var colorChaning = false
    var contentColorChanging = false
    
    var tapped: Bool {
        get {
            return colorChaning || contentColorChanging
        }
    }
    var onTapped: ((CircleButton)-> Void)?
    
    private var content: SKNode!
    var contentOnChanged: ((SKNode, SKColor)-> Void)?
    
    private func build() {
        self.lineWidth = CircleButton.outlineLineWidth
        self.userInteractionEnabled = true
        self.strokeColor = CircleButton.strokeColorNormal
        self.fillColor = CircleButton.fillColorNormal
        
        self.addChild(content)
        self.contentOnChanged?(self.content, CircleButton.contentColorNormal)
    }

    static func make(content: SKNode, contentOnChanged: ((SKNode, SKColor)-> Void)?, onTapped: ((CircleButton)-> Void)?)-> CircleButton {
        
        let button = CircleButton(circleOfRadius: radius)
        
        button.content = content
        button.contentOnChanged = contentOnChanged
        button.onTapped = onTapped
        
        button.build()
        
        return button
    }
    
    static func shape(content: SKShapeNode, onTapped: ((CircleButton)-> Void)?)-> CircleButton {
        
        return CircleButton.make(content, contentOnChanged: {node, color in
            
            let shapeNode = node as! SKShapeNode
            shapeNode.fillColor = color
            shapeNode.strokeColor = color
            
        }, onTapped: onTapped)
    }
    
    static func fa(iconName: String, dFontSize: Int, dx: Int, dy: Int, onTapped: ((CircleButton)-> Void)?)-> CircleButton {
        
        let icon = SKLabelNode()
        icon.fontName = FA.FONT
        icon.text = iconName
        icon.fontSize = 100 + CGFloat(dFontSize)
        icon.horizontalAlignmentMode = .Center
        icon.position.x = CGFloat(dx)
        icon.position.y = -icon.frame.height / 2 + CGFloat(7) + CGFloat(dy)
        
        return CircleButton.make(icon, contentOnChanged: {content, color in
            
            let faNode = content as! SKLabelNode
            faNode.fontColor = color
            
        }, onTapped: onTapped)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        // on tapped
        if tapped {
            return
        }
        
        let duration = NSTimeInterval(0.2)
        
        // change button color
        self.colorChaning = true
        self.runAction(SKAction.sequence([
            SKAction.customActionWithDuration(duration / 2, actionBlock: {node, elapsedTime in
                self.fillColor = self.changeColor(CircleButton.fillColorNormal, toColor: CircleButton.fillColorTapped, duration: duration / 2, elapsedTime: elapsedTime)
                self.strokeColor = self.changeColor(CircleButton.strokeColorNormal, toColor: CircleButton.strokeColorTapped, duration: duration / 2, elapsedTime: elapsedTime)
            }),
            SKAction.customActionWithDuration(duration / 2, actionBlock: {node, elapsedTime in
                self.fillColor = self.changeColor(CircleButton.fillColorTapped, toColor: CircleButton.fillColorNormal, duration: duration / 2, elapsedTime: elapsedTime)
                self.strokeColor = self.changeColor(CircleButton.strokeColorTapped, toColor: CircleButton.strokeColorNormal, duration: duration / 2, elapsedTime: elapsedTime)
            }),
            SKAction.runBlock({
                self.colorChaning = false
            })
        ]))
        
        // change content color
        self.contentColorChanging = true
        self.runAction(SKAction.sequence([
            SKAction.customActionWithDuration(duration / 2, actionBlock: {node, elapsedTime in
                let contentColor = self.changeColor(CircleButton.contentColorNormal, toColor: CircleButton.contentColorTapped, duration: duration / 2, elapsedTime: elapsedTime)
                self.contentOnChanged?(self.content, contentColor)
            }),
            SKAction.customActionWithDuration(duration / 2, actionBlock: {node, elapsedTime in
                let contentColor = self.changeColor(CircleButton.contentColorTapped, toColor: CircleButton.contentColorNormal, duration: duration / 2, elapsedTime: elapsedTime)
                self.contentOnChanged?(self.content, contentColor)
            }),
            SKAction.runBlock({
                self.contentColorChanging = false
            })
        ]))
        
        // play sound
        Av.share().tapButton.play()
        self.onTapped?(self)
    }
    
    private func changeColor(fromColor: SKColor, toColor: SKColor, duration: NSTimeInterval, elapsedTime: CGFloat)-> SKColor {
        
        let fromColorComponents = CGColorGetComponents(fromColor.CGColor)
        let toColorComponents = CGColorGetComponents(toColor.CGColor)
        
        func makeColor(index: Int)-> CGFloat {
            
            let start = fromColorComponents[index]
            let stop = toColorComponents[index]
            let color = start + (stop - start) * (CGFloat(elapsedTime) / CGFloat(duration))
            return color
        }
        
        return SKColor(red: makeColor(0), green: makeColor(1), blue: makeColor(2), alpha: makeColor(3))
    }
}

