//
//  PlayHeaderView.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import AVFoundation

fileprivate let xOffset: CGFloat = 0.5

class PlayHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        backgroundColor = .clear
        NotificationCenter.default.addObserver(self, selector: #selector(clearPlayerHead(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc
    func clearPlayerHead(_ notification: Notification) {
        reset()
    }
    
    func synchronize(with playerItem: AVPlayerItem) {
        reset()
        var timeRect = CGRect(x: 0, y: 0, width: 4, height: layer.bounds.size.height)
        let redLineLayer = CAShapeLayer()
        redLineLayer.frame = timeRect
        let path = UIBezierPath(rect: timeRect)
        redLineLayer.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.4).cgColor
        redLineLayer.path = path.cgPath
        
        timeRect.origin.x = 0
        timeRect.size.width = 1
        
        let timeMarkerWhiteLineLayer = CAShapeLayer()
        timeMarkerWhiteLineLayer.frame = timeRect
        timeMarkerWhiteLineLayer.position = CGPoint(x: 2, y: bounds.size.height/2)
        let whiteLinePath = UIBezierPath(rect: timeRect)
        timeMarkerWhiteLineLayer.fillColor = UIColor.white.cgColor
        timeMarkerWhiteLineLayer.path = whiteLinePath.cgPath
        
        redLineLayer.addSublayer(timeMarkerWhiteLineLayer)
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = xPosition(for: .zero)
        animation.toValue = xPosition(for: playerItem.duration)
        animation.isRemovedOnCompletion = false
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.duration = CMTimeGetSeconds(playerItem.duration)
        animation.fillMode = .both
        redLineLayer.add(animation, forKey: nil)
        
        // Synchronize redline with player item timing
        let syncLayer = AVSynchronizedLayer(playerItem: playerItem)
        syncLayer.addSublayer(redLineLayer)
        
        layer.addSublayer(syncLayer)
        layer.setNeedsDisplay()
    }
    
    func xPosition(for time: CMTime) -> CGFloat {
        let point = GetOrigin(for: time)
        return point.x + xOffset
    }
     
    func reset() {
        layer.sublayers = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
 
}
