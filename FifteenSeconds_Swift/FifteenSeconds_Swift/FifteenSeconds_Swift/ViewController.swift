//
//  ViewController.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var timelineVC: TimeLineViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        timelineVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TimeLineViewController")
        view.addSubview(timelineVC.view)
        addChild(timelineVC)
        
        timelineVC.view.frame = CGRect(x: 0, y: view.bounds.size.height / 2, width: view.bounds.size.width, height: view.bounds.size.height / 2)

    }

    @IBAction func tapAddItem(_ sender: Any) {
        
        let pickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PickerTabBarController") as PickerTabBarController
        pickerVC.playbackMediator = self
        navigationController?.pushViewController(pickerVC, animated: true)
        
    }
    
}

extension ViewController: PlaybackMediator {
    func loadMediaItem(item: MediaItem) {
        
    }
    func previewMediaItem(item: MediaItem) {
        
    }
    func addMediaItem(item: MediaItem, toTimelineTrack: MediaTrackType) {
        timelineVC.addTimelineItem(item: item, to: toTimelineTrack)
    }
    func prepareTimelineForPlayback() {
        
    }
    func stopPlayback() {
        
    }
}

