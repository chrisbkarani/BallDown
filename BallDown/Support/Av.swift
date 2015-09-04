//
//  Av.swift
//  BallDown
//
//  Copyright (c) 2015 ones. All rights reserved.
//

import Foundation
import AVFoundation

class Player {
    
    private let player: AVAudioPlayer?
    
    init(contentsOfURL: String, numberOfLoops: Int) {
        
        println("av create \(contentsOfURL)")
        let resourceUrl = NSBundle.mainBundle().URLForResource(contentsOfURL, withExtension: nil)
        let avError = NSErrorPointer()
        let player = AVAudioPlayer(contentsOfURL: resourceUrl!, error: avError)
        if player == nil {
            println("av can not play resource: \(contentsOfURL)")
        }
        player?.prepareToPlay()
        player?.numberOfLoops = numberOfLoops
        self.player = player
    }
    func play() {
        player?.play()
    }
    func pause() {
        player?.pause()
    }
}
class Av {
    
    private static let me = Av()
    
    static func share()-> Av {
        return me
    }
    
    let collide = Player(contentsOfURL: "collide.wav", numberOfLoops: 1)
    let tapButton = Player(contentsOfURL: "tapButton.wav", numberOfLoops: 1)
    let gameOver = Player(contentsOfURL: "gameOver.wav", numberOfLoops: 1)
    
}
