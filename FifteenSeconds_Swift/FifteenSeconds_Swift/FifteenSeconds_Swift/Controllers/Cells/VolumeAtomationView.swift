//
//  VolumeAtomationView.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import CoreMedia

class VolumeAutomationView: UIView {
    var audioRamps: [VolumeAutomation]? {
        didSet{
            setNeedsDisplay()
        }
    }
    var duration: CMTime? {
        didSet {
            scaleFactor = bounds.width / CGFloat(CMTimeGetSeconds(duration ?? .zero)) 
        }
    }
    
    var scaleFactor: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    func xForTime(time: CMTime) -> CGFloat {
        let xTime = CMTimeSubtract(duration!, CMTimeSubtract(duration!, time))
        return CGFloat(CMTimeGetSeconds(xTime)) * (scaleFactor ?? 0)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: bounds.height)
        context?.scaleBy(x: 1, y: -1)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        let rectHeight = bounds.height
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x, y: y))
        
        for automation in audioRamps ?? [] {
            x = xForTime(time: automation.timeRange.start)
            y = automation.startVolume * rectHeight
            path.addLine(to: CGPoint(x: x, y: y))
            
            x = x + GetWidthFor(timeRange: automation.timeRange, scaleFactor: scaleFactor!)
            y = automation.endVolume * rectHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        context?.setFillColor(UIColor(white: 1, alpha: 0.75).cgColor)
        context?.addPath(path)
        context?.drawPath(using: .fill)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
