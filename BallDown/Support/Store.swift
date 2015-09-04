//
//  Store.swift
//  BallDown
//
//  Copyright (c) 2015 ones. All rights reserved.
//

import Foundation
import StoreKit

class Store: NSObject, SKStoreProductViewControllerDelegate, UIAlertViewDelegate {
    
    private static var me = Store()
    
    static func share()-> Store {
        return me
    }
    
    var storeAlertAtCount = 0
    
    func tryShow(storeAlertAtCount: Int) {
        
        if !World.isConnected() {
            return
        }
        
        self.storeAlertAtCount = storeAlertAtCount
        UserDefaults.share().lastStoreAlertAtCount = storeAlertAtCount
        
        let title = NSLocalizedString("storeAlertTitle", comment: "")
        let message = NSLocalizedString("storeAlertMessage", comment: "")
        let yesTitle = NSLocalizedString("storeAlertYes", comment: "")
        let noTitle = NSLocalizedString("storeAlertNo", comment: "")
        
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: noTitle, otherButtonTitles: yesTitle)
        alertView.show()
    }
    
    private func show() {
        
        if !World.isConnected() {
            return
        }
        
        let currentViewController = AppDelegate.gameController!
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [SKStoreProductParameterITunesItemIdentifier: NSNumber(integer: World.appId)]
        
        storeViewController.loadProductWithParameters(parameters, completionBlock: {result, error in
            
            if result {
                currentViewController.presentViewController(storeViewController, animated: true, completion: nil)
            }
            
            println("store load product \(World.appId) \(result) error \(error)")
        })
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        println("store dismiss product view controller")
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        let clickPositive = buttonIndex > 0
        if clickPositive {
            show()
        }
        else {
            let title = ""
            let message = NSLocalizedString("storeRejectMessage", comment: "")
            
            let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: nil)
            
            alertView.show()
            NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("dismissAlertView:"), userInfo: alertView, repeats: false)
 
        }
        println("store alert view click positive \(clickPositive)")
    }
    func dismissAlertView(timer: NSTimer) {
        
        println("store dismiss reject alert view")
        let alertView = timer.userInfo as! UIAlertView
        alertView.dismissWithClickedButtonIndex(0, animated: true)
    }
}
