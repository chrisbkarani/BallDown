//
//  GameCenter.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import GameKit

class GameCenter: NSObject, GKGameCenterControllerDelegate {
    
    private override init() {
        
    }
    
    private static let me = GameCenter()
    
    static func share()-> GameCenter {
        return me
    }
    
    var authenticated: Bool {
        get {
            return GKLocalPlayer.localPlayer().authenticated
        }
    }
    
    private var tryShowLeaderboardCountWithoutAuth = 0
    
    func auth(viewController: UIViewController?, showLogin: Bool) {
        
        println("GameCenter auth showLogin \(showLogin)")
        
        if GKLocalPlayer.localPlayer().authenticated {
            return
        }
        if !World.isConnected() {
            return
        }
        tryShowLeaderboardCountWithoutAuth++
        if tryShowLeaderboardCountWithoutAuth > 3 {
            
            println("GameCenter try too much auth \(tryShowLeaderboardCountWithoutAuth)")
            return
        }
        
        GKLocalPlayer.localPlayer().authenticateHandler = { (gkViewController, error) -> Void in
            
            if error != nil {
                println("GameCenter auth error: \(error)")
            }
            else if gkViewController != nil && viewController != nil && showLogin {
                println("GameCenter show auth viewController")
                viewController!.presentViewController(gkViewController!, animated: true, completion: nil)
            }
            else {
                let directAuth = GKLocalPlayer.localPlayer().authenticated
                println("GameCenter auth \(directAuth)")
            }
        }
    }
    
    func showLeaderboard(viewController: UIViewController) {
        
        println("GameCenter request show leaderboard")
        
        if !GKLocalPlayer.localPlayer().authenticated {
            
            auth(viewController, showLogin: true)
            return
        }
        
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    private var bestScorePending = 0
    
    private func reportScore() {
        
        if !GKLocalPlayer.localPlayer().authenticated {
            return
        }
        
        let score = bestScorePending
        
        let scoreToReport = GKScore(leaderboardIdentifier: "main")
        scoreToReport.value = Int64(score)
        let scoresToReport = [scoreToReport]
        
        GKScore.reportScores(scoresToReport, withCompletionHandler: {(error: NSError!)-> Void in
            
            println("GameCenter report score \(score) error \(error)")
            
            if score >= self.bestScorePending {
                self.bestScorePending = 0
            }
            
            // success update
            if error == nil {
                if score > UserDefaults.share().bestScoreOnLeaderboard {
                    UserDefaults.share().bestScoreOnLeaderboard = score
                }
            }
        })
        
    }
    
    func tick() {
        
        let bestScoreLocal = UserDefaults.share().bestScore
        let bestScoreOnLeaderboard = UserDefaults.share().bestScoreOnLeaderboard
        if bestScoreLocal <= bestScoreOnLeaderboard || bestScoreLocal <= bestScorePending {
            return
        }
        
        bestScorePending = bestScoreLocal
        reportScore()
    }
    
    @objc func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        println("GameCenter gameCenterViewController did finish")
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}