//
//  FilterSelectorView.swift
//  WriteReadMedia
//
//  Created by 壹九科技1 on 2020/4/21.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class FilterSelectorView: UIView {
    var leftButton: UIButton!
    var scrollView: UIScrollView!
    var rightButton: UIButton!
    var labels: Array<UILabel>?
    var activeLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        leftButton = UIButton()
        leftButton.setImage(UIImage(named: "left_arrow"), for: .normal)
        leftButton.frame = CGRect(x: 20, y: 0, width: 48, height: 48)
        addSubview(leftButton)
        
        rightButton = UIButton()
        rightButton.setImage(UIImage(named: "right_arrow"), for: .normal)
        rightButton.frame = CGRect(x: frame.width - 20 - 48, y: 0, width: 48, height: 48)
        addSubview(rightButton)
        
        scrollView = UIScrollView()
        scrollView.frame = CGRect(x: leftButton.frame.maxX + 10, y: 0, width: frame.width - 40 - 100 - 50, height: 48)
        addSubview(scrollView)

        setupLabels()
        setupActions()
        
        leftButton.addTarget(self, action: #selector(pageLeft(_:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(pageRight(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func setupLabels() {
        let filterNames = PhotoFilters.filterNames()
        var frame = scrollView.bounds
        labels = [UILabel]()
        for text in filterNames {
            let label = UILabel(frame: frame)
            label.backgroundColor = .clear
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.text = text
            scrollView.addSubview(label)
            frame.origin.x += frame.size.width
            labels?.append(label)
        }
        activeLabel = labels?.first
        let width = frame.width * CGFloat(labels?.count ?? 0)
        scrollView.contentSize = CGSize(width: width, height: 0)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func setupActions() {
        leftButton.isEnabled = false
        
    }

    
    @objc func pageLeft(_ sender: Any) {
        guard let labelIndex = labels?.firstIndex(of: activeLabel!) else { return }
        if labelIndex > 0 {
            let label = labels?[labelIndex - 1]
            scrollView.setContentOffset(CGPoint(x: label?.frame.origin.x ?? 0, y: 0), animated: true)
            activeLabel = label
            rightButton.isEnabled = true
            postNotificationForChange(displayName: label?.text ?? "")
        }
        leftButton.isEnabled = labelIndex - 1 > 0
    }
    
    
    
    @objc func pageRight(_ sender: Any) {
        guard let labelIndex = labels?.firstIndex(of: activeLabel!) else { return }
        if labelIndex < (labels?.count ?? 0) - 1 {
            let label = labels?[labelIndex + 1]
            scrollView.setContentOffset(CGPoint(x: label?.frame.origin.x ?? 0, y: 0), animated: true)
            activeLabel = label
            leftButton.isEnabled = true
            postNotificationForChange(displayName: label?.text ?? "")
        }
        rightButton.isEnabled = labelIndex < ((self.labels?.count ?? 0) - 1)
    }
    
    func postNotificationForChange(displayName: String) {
        let filter = PhotoFilters.filterForDisplayName(displayName)
        NotificationCenter.default.post(name: THFilterSelectionChangedNotification, object: filter)
    }
    
}
