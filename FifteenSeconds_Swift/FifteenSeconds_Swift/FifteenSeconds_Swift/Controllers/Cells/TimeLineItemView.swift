//
//  TimeLineItemView.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class TimeLineItemView: UIView {
    var titleLabel: UILabel! = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        layer.cornerRadius = 4
        layer.borderWidth = 2
        layer.borderColor = UIColor(white: 1, alpha: 0.25).cgColor
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: bounds.origin.x + 10, y: bounds.origin.y + 10, width: bounds.width - 10, height: bounds.height - 10)
        
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
}
