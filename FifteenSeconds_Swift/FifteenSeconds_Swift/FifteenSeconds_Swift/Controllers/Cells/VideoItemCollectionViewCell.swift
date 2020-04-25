//
//  VideoItemCollectionViewCell.swift
//  FifteenSeconds_Swift
//
//  Created by 壹九科技1 on 2020/4/23.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import CoreMedia

class VideoItemCollectionViewCell: UICollectionViewCell {
    var itemView: TimeLineItemView!
    var maxTimeRagne: CMTimeRange!
    
    var trimmerImageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        itemView = TimeLineItemView(frame: bounds)
        contentView.addSubview(itemView)
    }
    
    func isPointInDragHandle(point: CGPoint) -> Bool {
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemView.frame = self.bounds
    }
}
