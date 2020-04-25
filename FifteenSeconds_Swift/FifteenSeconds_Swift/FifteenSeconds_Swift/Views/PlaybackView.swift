//
//  PlaybackView.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import AVKit

class PlaybackView: UIView {
    var player: AVPlayer? {
        set {
            (layer as! AVPlayerLayer).videoGravity = .resizeAspectFill
            (layer as! AVPlayerLayer).player = newValue
        }
        get {
            return (layer as! AVPlayerLayer).player
        }
    }
   
    override class var layerClass: AnyClass {
        get {
            AVPlayerLayer.self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .black
    }
    
    
    
}
