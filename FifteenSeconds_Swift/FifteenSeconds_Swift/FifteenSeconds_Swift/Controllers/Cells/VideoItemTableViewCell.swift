//
//  VideoItemTableViewCell.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class VideoItemTableViewCell: UITableViewCell {

    var tapAddButtonBlock: (() -> Void)?
    
    var overlayView: VideoPickerOverlayView!
    
    var playButton: UIButton! {
        get {
            return overlayView.playButton
        }
    }
    var addButton: UIButton! {
        get {
            return overlayView.addButton
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundView = ThumbnailsView(frame: bounds)
        contentView.backgroundColor = .clear
        overlayView = VideoPickerOverlayView(frame: bounds)
        contentView.addSubview(overlayView)
        
        overlayView.addButton.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)

    }
    
    @objc
    func tapAddButton() {
        tapAddButtonBlock?()
    }

    func setThumbnails(thumbnails: [UIImage]) {
        (backgroundView as! ThumbnailsView).thumbnails = thumbnails
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        overlayView.isHidden = !selected
        if !selected {
            overlayView.playButton.isEnabled = false
        } else {
            overlayView.playButton.isEnabled = true
        }
    }
    
    
}
