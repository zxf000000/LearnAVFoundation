//
//  TransitionButton.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class TransitionButton: UIButton {
    var transitionType: VideoTransitionType? {
        didSet {
            updateBackgroundImage()
        }
    }
    
    var typeToNameMap: [VideoTransitionType: String]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        transitionType = VideoTransitionType.none
        
        typeToNameMap = [
            VideoTransitionType.none: "trans_btn_bg_none",
            VideoTransitionType.dissolve: "trans_btn_bg_xfade",
            VideoTransitionType.push: "trans_btn_bg_push"
        ]
        updateBackgroundImage()
    }
    
    func updateBackgroundImage() {
        guard let imageName = typeToNameMap?[transitionType!] else { return }
        setBackgroundImage(UIImage(named: imageName), for: .normal)
        
    }
}
