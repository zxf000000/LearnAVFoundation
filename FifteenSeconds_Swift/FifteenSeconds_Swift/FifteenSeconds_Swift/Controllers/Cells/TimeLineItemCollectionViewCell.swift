//
//  TimeLineItemCollectionViewCell.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class TimeLineItemCollectionViewCell: UICollectionViewCell {
    var itemView: TimeLineItemView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        itemView = TimeLineItemView(frame: bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemView.frame = bounds
    }
}
