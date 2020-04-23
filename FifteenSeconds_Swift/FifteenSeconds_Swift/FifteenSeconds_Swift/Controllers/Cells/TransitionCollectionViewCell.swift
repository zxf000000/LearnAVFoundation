//
//  TransitionCollectionViewCell.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class TransitionCollectionViewCell: UICollectionViewCell {
    var transitionButton: TransitionButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        transitionButton = TransitionButton(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        contentView.addSubview(transitionButton)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        transitionButton = TransitionButton(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        contentView.addSubview(transitionButton)
        
    }
}
