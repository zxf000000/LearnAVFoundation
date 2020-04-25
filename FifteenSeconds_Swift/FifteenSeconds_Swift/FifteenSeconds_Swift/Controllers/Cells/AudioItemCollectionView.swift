//
//  AudioItemCollectionView.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class AudioItemCollectionViewCell: UICollectionViewCell {
    var itemView: TimeLineItemView!
    var audioAutomationView: VolumeAutomationView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        itemView.frame = bounds
        audioAutomationView.frame = CGRect(x: 0, y: 10, width: frame.width, height: frame.height)
    }
    
    func setup() {
        itemView = TimeLineItemView(frame: frame)
        contentView.addSubview(itemView)
        
        audioAutomationView = VolumeAutomationView(frame: CGRect(x: 0, y: 10, width: frame.width, height: frame.height))
        contentView.addSubview(audioAutomationView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
}
