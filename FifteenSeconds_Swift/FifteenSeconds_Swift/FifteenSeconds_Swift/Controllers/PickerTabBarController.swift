//
//  PickerTabBarController.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class PickerTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Video Picker"
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if tabBar.items?.firstIndex(of: item) == 0 {
            title = "Video Picker"
        } else {
            title = "Audio Picker"
        }
    }
  
}
