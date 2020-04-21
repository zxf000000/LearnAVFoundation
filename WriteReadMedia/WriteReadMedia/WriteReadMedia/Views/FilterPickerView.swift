//
//  FilterPickerView.swift
//  WriteReadMedia
//
//  Created by 壹九科技1 on 2020/4/21.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class FilterPickerView: UIView {
    var thumbnails: [UIView]?
    var scrollView: UIScrollView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        scrollView = UIScrollView(frame: bounds)
        addSubview(scrollView)
    }
    
    func setFilterThumbnailViews() {
        var currentX: CGFloat = 0
        let firstView = thumbnails?.first
        let size = firstView?.frame.size
        let width = size?.width ?? 0 * CGFloat(thumbnails?.count ?? 0)
        scrollView.contentSize = CGSize(width: width ?? 0, height: size?.height ?? 0)
        for i in 0..<(thumbnails?.count ?? 0) {
//            let
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func buildScrubber(notification: Notification) {
        
    }
}
