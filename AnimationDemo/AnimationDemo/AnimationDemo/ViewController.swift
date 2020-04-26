//
//  ViewController.swift
//  AnimationDemo
//
//  Created by mr.zhou on 2020/4/26.
//  Copyright © 2020 mr.zhou. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var asset: AVAsset!
    
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var animationLayer: AVSynchronizedLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let path = Bundle.main.path(forResource: "test1", ofType: "mp4") else {return}
        let url = URL(fileURLWithPath: path)
        asset = AVURLAsset(url: url)
        
        
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = CGRect(x: 0, y: 100, width: view.bounds.size.width, height: 300)
        view.layer.addSublayer(playerLayer)

        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if playerItem.status == .readyToPlay {
            player.play()
            
            animationLayer = AVSynchronizedLayer(playerItem: playerItem)
            
            animationLayer.frame = playerLayer.bounds
            playerLayer.addSublayer(animationLayer)
            
            let textLayer = CATextLayer()
            textLayer.string = "test animation"
            textLayer.font = UIFont.systemFont(ofSize: 30)
            textLayer.foregroundColor = UIColor.red.cgColor
            
            let animation = CABasicAnimation(keyPath: "transform.rotation.y")
            animation.beginTime = 5
            animation.duration = 2
            animation.fromValue = 0
            animation.toValue = 10
            animation.repeatCount = 10
            animation.isRemovedOnCompletion = false
            animation.fillMode = .both
            textLayer.add(animation, forKey: nil)
            
            textLayer.frame = CGRect(x: 0, y: 50, width: view.bounds.width, height: 100)
            
            animationLayer.addSublayer(textLayer)
            
            
        }
    }

}

