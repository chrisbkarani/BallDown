//
//  Share.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import SpriteKit
import Social
import SystemConfiguration

class ShareButtonGroup: SKNode {
    
    let openDuration = 0.2
    let verticalBetween = CGFloat(150)
    let downloadUrl = "https://itunes.apple.com/app/id\(World.appId)?mt=8"
    let logoImageName = "logo"
    
    var controllBtn: CircleButton!
    var isOpen = false
    
    weak var game: GameScene?
    
    static func make(game: GameScene)-> ShareButtonGroup {
        
        let group = ShareButtonGroup()
        group.game = game
        
        group.build()
        
        return group
    }
    
    private func build() {
        
        var group: [SKNode] = []
        
        // facebook
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let facebookBtn = CircleButton.fa(FA.facebook, dFontSize: 0, dx: 0, dy: 0, onTapped: {[unowned self] node in
                println("share facebook tapped")
                self.shareByIOS(SLServiceTypeFacebook, localKey: "shareContentByFacebook")
            })
            group.append(facebookBtn)
        }
        
        // twitter
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let twitterBtn = CircleButton.fa(FA.twitter, dFontSize: -5, dx: 5, dy: -10, onTapped: {[unowned self] node in
                println("share twitter tapped")
                self.shareByIOS(SLServiceTypeTwitter, localKey: "shareContentByTwitter")
            })
            group.append(twitterBtn)
        }
        
        // wechat
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            let wechatBtn = CircleButton.fa(FA.weixin, dFontSize: -15, dx: 0, dy: 0, onTapped: {[unowned self] node in
                
                self.close()
                
                if self.game == nil {
                    return
                }
                let score = self.game!.score
                let text = String(format: NSLocalizedString("shareContentByWechat", comment: ""), arguments: [score])
                println("share wechat tapped")
                let message = WXMediaMessage()
                message.title = text
                message.description = text
                message.setThumbImage(UIImage(named: self.logoImageName))
                
                let ext = WXWebpageObject()
                ext.webpageUrl = self.downloadUrl
                
                message.mediaObject = ext
                message.mediaTagName = "WECHAT_TAG_JUMP_SHOWRANK"
                
                let req = SendMessageToWXReq()
                req.bText = false;
                req.message = message;
                req.scene = Int32(WXSceneTimeline.value)
                WXApi.sendReq(req)
            })
            group.append(wechatBtn)
            
        }
        
        // sina
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo) {
            let weiboBtn = CircleButton.fa(FA.weibo, dFontSize: -10, dx: 0, dy: 0, onTapped: {[unowned self] node in
                println("share weibo tapped")
                self.shareByIOS(SLServiceTypeSinaWeibo, localKey: "shareContentByWeibo")
            })
            group.append(weiboBtn)
        }
        
        if group.count > 0 {
            
            controllBtn = CircleButton.fa(FA.share_alt, dFontSize: 0, dx: -5, dy: 0, onTapped: {[unowned self] node in
                
                println("share share tapped")
                if !self.isOpen {
                    self.open()
                }
                else {
                    self.close()
                }
            })
            controllBtn.hidden = false
            controllBtn.zPosition = 10
            self.addChild(controllBtn)
            
            for btn in group {
                btn.hidden = true
                self.addChild(btn)
            }
        }
    }
    func close() {
        if isOpen {
            isOpen = false
            for btn in self.children as! [SKNode] {
                if btn != self.controllBtn {
                    btn.runAction(SKAction.sequence([
                        SKAction.moveToY(CGFloat(0), duration: openDuration),
                        SKAction.runBlock({() in
                            btn.hidden = true
                        })
                        ]))
                }
            }
        }
    }
    private func open() {
        if !isOpen {
            isOpen = true
            var moveUpDistance = CGFloat(0)
            for btn in self.children as! [SKNode] {
                if btn != self.controllBtn {
                    moveUpDistance += verticalBetween
                    btn.position.y = 0
                    btn.runAction(SKAction.sequence([
                        SKAction.runBlock({() in
                            btn.hidden = false
                        }),
                        SKAction.moveBy(CGVectorMake(CGFloat(0), CGFloat(moveUpDistance)), duration: openDuration)
                    ]))
                }
            }
        }
    }
    private func shareByIOS(serviceType: String, localKey: String) {
        
        self.close()
        
        if SLComposeViewController.isAvailableForServiceType(serviceType) {
            if game == nil {
                return
            }
            let score = game!.score
            let textRaw = NSLocalizedString(localKey, comment: "")
            let text = String(format: textRaw, arguments: [score])
            
            let socialController = SLComposeViewController(forServiceType: serviceType)
            socialController.setInitialText(text)
            
            let image = screenshot()
            let width = CGFloat(450)
            let height = width * image.size.height / image.size.width
            UIGraphicsBeginImageContext(CGSizeMake(width, height))
            image.drawInRect(CGRectMake(0, 0, width, height))
            let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            socialController.addImage(resizeImage)
            socialController.addURL(NSURL(string: self.downloadUrl))
            socialController.completionHandler = {
                (result: SLComposeViewControllerResult) in
                switch result {
                case .Done:
                    println("user success share")
                case .Cancelled:
                    println("user cancel share")
                }
            }
            AppDelegate.gameController?.presentViewController(socialController, animated: true, completion: nil)
        }
    }
    private func screenshot()-> UIImage {
        let view = AppDelegate.gameController!.view
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 1)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage
    }
}