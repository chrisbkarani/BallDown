//
//  Ad.swift
//  BallDown
//
//  Copyright © 2015 ones. All rights reserved.
//

import Foundation
import iAd
import GoogleMobileAds

class Ad {
    
    private static var me: Ad!
    
    static func share()-> Ad {
        
        if me == nil {
            me = Ad()
            me.create()
        }
        return me
    }
    
    private let maxTryLoadCount = 10
    private var provider: AdProvider?
    
    var showing: Bool {
        get {
            return provider != nil && provider!.showing
        }
    }
    
    private func create() {
        
        provider = Ad.findProvider()
        provider?.create()
    }
    
    private static func findProvider()-> AdProvider? {
    
        var providerResult: AdProvider?
        let countryCode: AnyObject? = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode)
        for provider in Ad.providers() {
            if provider.isSupported(countryCode) {
                providerResult = provider
                break
            }
        }
        
        println("Ad countryCode \(countryCode) provider \(providerResult)")
        return providerResult
    }
    
    private static func providers()-> [AdProvider] {
        return [
            IAD(),
            GAD(),
        ]
    }
    
    func show()-> Bool {
        return provider != nil && provider!.show()
    }
}

class AdProvider : NSObject {
    
    var showing = false
    private var tryLoadCount = 0
    
    func isSupported(countryCode: AnyObject?)-> Bool {
        return true
    }
    
    func create() {
        
        if !World.isConnected() {
            return
        }
        
        tryLoadCount++
        let maxTryLoadCount = Ad.share().maxTryLoadCount
        
        println("Ad try load \(tryLoadCount) | \(maxTryLoadCount)")
        
        if tryLoadCount > maxTryLoadCount {
            destroy()
        }
        else {
            doCreate()
        }
    }
    
    func destroy() {
        showing = false
        doDestroy()
    }
    
    func show()-> Bool {
        
        var successToShow = false
        if !showing {
            
            successToShow = doShow()
            if successToShow {
                showing = true
            }
        }
        
        return successToShow
    }
    
    func callSuccessToLoad() {
        
        println("Ad success to load")
        tryLoadCount = 0
    }
    
    func callFailToLoad() {
        
        println("Ad fail to load")
        destroy()
        create()
    }
    
    func callCloseAd() {
        
        println("Ad close ad ui")
        showing = false
        destroy()
        create()
    }
    
    func doCreate() {
        
    }
    func doDestroy() {
        
    }
    func doShow() -> Bool {
        
        return false
    }
}

class IAD : AdProvider, ADInterstitialAdDelegate {
    
    var iAd: ADInterstitialAd?
    var iAdView: UIView?
    
    override func isSupported(countryCode: AnyObject?) -> Bool {
        
        if countryCode == nil {
            return false
        }
        
        let supportedCountries = NSSet(array: [
            "AU", // Australia
            "BR", // Brazil
            "CA", // Canada
            "CL", // Chile
            "FR", // France
            "DE", // Germany
            "GR", // Greece
            "HK", // Hong Kong
            "IN", // India
            "IT", // Italy
            "JP", // Japan
            "MX", // Mexico
            "NZ", // New Zealand
            "NO", // Norway
            "ES", // Spain
            "TW", // Taiwan
            "TH", // Thailand
            "TR", // Turkey
            "GB", // United Kingdom
            "US", // United States
        ])
        
        let supported = supportedCountries.containsObject(countryCode!)
        
        return supported
    }
    
    override func doCreate() {
        
        iAd = ADInterstitialAd()
        iAd!.delegate = self
    }
    override func doDestroy() {
        
        if self.iAdView != nil {
            self.iAdView!.removeFromSuperview()
            self.iAdView = nil
        }
    }
    
    override func doShow() -> Bool {
        
        var successToShow = iAd != nil && iAd!.loaded
        
        if successToShow {
            
            let gameView : UIView! = AppDelegate.gameController?.view
            
            self.iAdView = UIView(frame: gameView.bounds)
            self.iAdView!.alpha = 0
            UIView.animateWithDuration(1, animations: {
                self.iAdView!.alpha = 1
            })
            gameView.addSubview(self.iAdView!)
            
            iAd!.presentInView(self.iAdView!)
            
            let iAdCloseView = UIControl(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            iAdCloseView.addTarget(self, action: "onIAdCloseBtnTapped:", forControlEvents: UIControlEvents.TouchDown)
            
            iAdView!.addSubview(iAdCloseView)
            
            let iAdCloseBtn = newIAdCloseBtn()
            iAdCloseView.addSubview(iAdCloseBtn)
        }
        
        return successToShow
    }
    private func newIAdCloseBtn() -> UIButton {
        
        let closeBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        closeBtn.frame = CGRectMake(10, 10, 20, 20)
        closeBtn.layer.cornerRadius = 10
        closeBtn.setTitle("x", forState: .Normal)
        closeBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeBtn.backgroundColor = UIColor.whiteColor()
        closeBtn.layer.borderColor = UIColor.blackColor().CGColor
        closeBtn.layer.borderWidth = 1
        closeBtn.addTarget(self, action: "onIAdCloseBtnTapped:", forControlEvents: UIControlEvents.TouchDown)
        
        return closeBtn
    }
    func onIAdCloseBtnTapped(sender: UIButton) {
        callCloseAd()
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        println("iAd unload")
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        println("iAd error \(error)")
        callFailToLoad()
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        println("iAd will load")
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        println("iAd did load")
        callSuccessToLoad()
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        println("iAd action finish")
    }
}

class GAD : AdProvider, GADInterstitialDelegate {
    
    let gadUnitId = World.gadUnitId
    var gad: GADInterstitial?
    
    override func doCreate() {
        
        self.gad = GADInterstitial(adUnitID: self.gadUnitId)
        self.gad!.delegate = self
        self.gad!.loadRequest(GADRequest())
    }
    
    override func doDestroy() {
        
        self.gad = nil
    }
    
    override func doShow() -> Bool {
        
        var successToShow = self.gad != nil && self.gad!.isReady
        
        if successToShow {
            
            let rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController
            self.gad!.presentFromRootViewController(rootViewController)
        }
        return successToShow
    }
    
    /// Called when an interstitial ad request succeeded. Show it at the next transition point in your
    /// application such as when transitioning between view controllers.
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        
        callSuccessToLoad()
    }
    
    /// Called when an interstitial ad request completed without an interstitial to
    /// show. This is common since interstitials are shown sparingly to users.
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        
        callFailToLoad()
    }
    
    /// Called just before presenting an interstitial. After this method finishes the interstitial will
    /// animate onto the screen. Use this opportunity to stop animations and save the state of your
    /// application in case the user leaves while the interstitial is on screen (e.g. to visit the App
    /// Store from a link on the interstitial).
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        
    }
    
    /// Called before the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        
    }
    
    /// Called just after dismissing an interstitial and it has animated off the screen.
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        
        callCloseAd()
    }
    
    /// Called just before the application will background or terminate because the user clicked on an
    /// ad that will launch another application (such as the App Store). The normal
    /// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
    /// before this.
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        
    }
}