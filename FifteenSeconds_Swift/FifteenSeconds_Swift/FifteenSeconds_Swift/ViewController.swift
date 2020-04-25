//
//  ViewController.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

let EXPORTING_KEYPATH =       "exporting"
let PROGRESS_KEYPATH  =       "progress"

class ViewController: UIViewController {

    var timelineVC: TimeLineViewController!
    var playerVC: PlayerViewController!
    var factory: CompositionBuilderFactory! = CompositionBuilderFactory()
    var exporter: CompositionExporter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        timelineVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TimeLineViewController")
        view.addSubview(timelineVC.view)
        addChild(timelineVC)
        
        timelineVC.view.frame = CGRect(x: 0, y: view.bounds.size.height / 2, width: view.bounds.size.width, height: view.bounds.size.height / 2)
        
        playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlayerViewController")
        addChild(playerVC)
        view.addSubview(playerVC.view)
        
        playerVC.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height / 2)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(exportComposition(notification:)),
                                               name: ExportRequestedNotification,
                                               object: nil)
    }

    @IBAction func tapAddItem(_ sender: Any) {
        
        let pickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PickerTabBarController") as PickerTabBarController
        pickerVC.playbackMediator = self
        navigationController?.pushViewController(pickerVC, animated: true)
        
    }
    
    @IBAction func tapExport(_ sender: Any) {
        
        exportComposition(notification: Notification(name: Notification.Name.init(rawValue: "")))
        
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
        let timeline = timelineVC.currentTimeLine()
        let builder = factory.builder(for: timeline)
        let composition = builder?.buildComposition()
        guard let playerItem = composition?.makePlayable() else {return}
        timelineVC.synchronizePlayHead(with: playerItem)
        playerVC.play(item: playerItem)
    }
    func stopPlayback() {
        playerVC.stopPlayback()
    }
    @objc
    func exportComposition(notification: Notification) {
        let timeline = timelineVC.currentTimeLine()
        let builder = factory.builder(for: timeline)
        guard let composition = builder?.buildComposition() else {return}
        let exporter = CompositionExporter(compositon: composition)
        exporter.addObserver(self, forKeyPath: EXPORTING_KEYPATH, options: .new, context: nil)
        exporter.addObserver(self, forKeyPath: PROGRESS_KEYPATH, options: .new, context: nil)
        exporter.beginExport()
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == EXPORTING_KEYPATH {
            guard let exporting = change?[NSKeyValueChangeKey.newKey] as? Bool else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            playerVC.exporting = exporting
            if exporting == false {
                exporter.removeObserver(self, forKeyPath: EXPORTING_KEYPATH)
                exporter.removeObserver(self, forKeyPath: PROGRESS_KEYPATH)
            }
        } else if keyPath == PROGRESS_KEYPATH {
            guard let progress = change?[NSKeyValueChangeKey.newKey] as? CGFloat else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            playerVC.progressView.progress = Float(progress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

