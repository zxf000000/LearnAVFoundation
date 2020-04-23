//
//  PickerTabBarController.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class PickerTabBarController: UITabBarController {

    var playbackMediator: PlaybackMediator! {
        didSet {
            for vc in self.children {
                if let aVC = vc as? VideoPickerViewController {
                    aVC.mediaPlaybackMediator = playbackMediator
                }
                if let aVC = vc as? AudioPickerViewController {
                    aVC.playbackMediator = playbackMediator
                }
            }
        }
    }
    
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
