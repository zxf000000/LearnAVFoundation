//
//  VideoPickerOverlayView.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

let BUTTON_WIDTH: CGFloat = 44
let BUTTON_HEIGHT: CGFloat = 44
let STOP_INSETS: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
let PLAY_INSETS: UIEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)

class VideoPickerOverlayView: UIView {

    var playButton: UIButton!
    var pauseButton: UIButton!
    var addButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addButton = UIButton(type: .custom)
        playButton = UIButton(type: .custom)
        
        let bgImage = UIImage(named: "dark_button_background")
        addButton.setBackgroundImage(bgImage, for: .normal)
        playButton.setBackgroundImage(bgImage, for: .normal)
        
        addButton.setImage(UIImage(named: "tp_add_media_icon"), for: .normal)
        playButton.setImage(UIImage(named: "tp_play_icon"), for: .normal)
        playButton.setImage(UIImage(named: "tp_stop_icon"), for: .selected)
        
        playButton.imageEdgeInsets = PLAY_INSETS
        
        addSubview(playButton)
        addSubview(addButton)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let yPos = (bounds.height - BUTTON_HEIGHT)/2
        playButton.frame = CGRect(x: bounds.midX + 10, y: yPos, width: BUTTON_WIDTH, height: BUTTON_HEIGHT);

        addButton.frame = CGRect(x: bounds.midX - 10 - BUTTON_WIDTH, y: yPos, width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
