//
//  CaptureButton.swift
//  WriteReadMedia
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

enum CaptureButtonMode: Int {
    case Photo = 0
    case Video = 1
}

let LINE_WIDTH: CGFloat = 6.0
let DEFAULT_FRAME = CGRect(x: 0, y: 0, width: 68, height: 68)

class CaptureButton: UIButton {
    var captureButtonMode: CaptureButtonMode? {
        didSet {
            let toColor: UIColor = (captureButtonMode == .Video) ? .red : .white
            circleLayer?.backgroundColor = toColor.cgColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            fadeAnimation.duration = 0.2
            if isHighlighted {
                fadeAnimation.toValue = 0
            } else {
                fadeAnimation.toValue = 1
            }
            circleLayer?.opacity = fadeAnimation.toValue as! Float
            circleLayer?.add(fadeAnimation, forKey: "fadeAnimation")
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if captureButtonMode == .Video {
                CATransaction.disableActions()
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
                if isSelected {
                    scaleAnimation.toValue = 0.6
                    radiusAnimation.toValue = circleLayer?.bounds.size.width ?? 0 / 4
                } else {
                    scaleAnimation.toValue = 1
                    radiusAnimation.toValue = (circleLayer?.bounds.size.width) ?? 0 / 2
                }
                
                let animationGroup = CAAnimationGroup()
                animationGroup.animations = [scaleAnimation, radiusAnimation]
                animationGroup.beginTime = CACurrentMediaTime() + 0.2
                animationGroup.duration = 0.35
                
                circleLayer?.cornerRadius = radiusAnimation.toValue as! CGFloat
                circleLayer?.setValue(scaleAnimation.toValue, forKeyPath: "transform.scale")
                circleLayer?.add(animationGroup, forKey: "scaleAndRadiusAnimation")
            }
        }
    }
    
    
    private var circleLayer: CALayer?
    
    init(mode: CaptureButtonMode) {
        super.init(frame: DEFAULT_FRAME)
        self.captureButtonMode = mode
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.captureButtonMode = .Video
        setupView()
    }
    
    func setupView() {
        backgroundColor = .clear
        tintColor = .clear
        let circleColor: UIColor = (captureButtonMode == .Video) ? .red : .white
        circleLayer = CALayer()
        circleLayer?.backgroundColor = circleColor.cgColor
        circleLayer?.bounds = self.bounds.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        circleLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY)
        circleLayer?.cornerRadius = (circleLayer?.bounds.width)! / 2
        layer.addSublayer(circleLayer!)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setFillColor(UIColor.white.cgColor)
        context?.setLineWidth(LINE_WIDTH)
        let insetRect = rect.inset(by: UIEdgeInsets(top: LINE_WIDTH, left: LINE_WIDTH, bottom: LINE_WIDTH , right: LINE_WIDTH ))
        context?.strokeEllipse(in: insetRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.captureButtonMode = .Video
    }
    
}
