//
//  WaveFormView.swift
//  PlayerDemo
//
//  Created by 壹九科技1 on 2020/4/11.
//  Copyright © 2020 YJKJ. All rights reserved.
//

import UIKit
import AVFoundation

let WidthScaling: CGFloat = 0.8
let heightScaling: CGFloat = 0.85

class WaveFormView: UIView {

    var asset: AVAsset? {
        didSet {
            SampleDataProvider.loadAudioSamples(from: asset!) { (data) in
                self.filter = SampleDataFilter(data)
                self.setNeedsDisplay()
            }
        }
    }
    var waveColor: UIColor! = UIColor.green

    private var filter: SampleDataFilter?
    private var loadingView: UIActivityIndicatorView! = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadingView.hidesWhenStopped = true
        loadingView.startAnimating()
        loadingView.color = .white
        loadingView.tintColor = .white
        addSubview(loadingView)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadingView.center = center
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        
        
        if asset == nil || filter == nil {
            return
        }
        loadingView.stopAnimating()
        
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: WidthScaling, y: heightScaling)
        
        let xOffset = (self.bounds.size.width - bounds.size.width * WidthScaling) / 2
        let yOffset = (bounds.size.height - bounds.size.height * heightScaling) / 2
        context?.translateBy(x: xOffset, y: yOffset)
        
        let filteredSamples = filter?.filterSample(for: bounds.size)
        let midY = rect.midY
        
        let halfPath = CGMutablePath()
        halfPath.move(to: CGPoint(x: 0, y: midY))
        
        guard let filterSamples = filteredSamples else {
            return
        }
        
        for i in 0..<filterSamples.count {
            let sample = filterSamples[i]
            halfPath.addLine(to: CGPoint(x: CGFloat(i), y: midY - sample))
        }
        
        halfPath.addLine(to: CGPoint(x: CGFloat(filterSamples.count), y: midY))
        
        let fullPath = CGMutablePath()
        fullPath.addPath(halfPath)
        
        
        
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: rect.height)
        transform = transform.scaledBy(x: 1, y: -1)
        fullPath.addPath(halfPath, transform: transform)
        
        context?.addPath(fullPath)
        context?.setFillColor(waveColor.cgColor)
        context?.drawPath(using: .fill)

    }
    
    
}
