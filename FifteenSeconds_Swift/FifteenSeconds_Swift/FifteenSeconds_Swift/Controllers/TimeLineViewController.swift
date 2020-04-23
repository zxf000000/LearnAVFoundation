//
//  TimeLineViewController.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import AVKit

class TimeLineViewController: UIViewController {
    var transitionEnabled: Bool? {
        didSet {
            var items = [Any]()
            for item in timelineDataSource?.timelineItems?[MediaTrackType.video.rawValue] ?? [] {
                if (item as AnyObject).isKind(of: TimelineItemViewModel.self) {
                    guard let model = item as? TimelineItemViewModel else {return}
                    items.append(model)
                    if transitionEnabled == true && items.count % 2 != 0 {
                        items.append(VideoTransition.dissolveTransition(with: CMTimeMake(value: 1, timescale: 2)))
                    }
                }
            }
            if let _ = items.last as? VideoTransition {
                items.removeLast()
            }
            timelineDataSource?.timelineItems?[MediaTrackType.video.rawValue] = items
        }
    }
    var volumeFadesEnabled: Bool?
    var duckingEnabled: Bool?
    var titlesEnabled: Bool?
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cellIDs: [String]?
    private var timelineDataSource: TimelineDataSource?
    private var transitionPopoverController: UIPopoverController?
    private var playHeadView: PlayHeaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitionEnabled = AppSettings.shared.transitionEnabled
        volumeFadesEnabled = AppSettings.shared.volumeFadesEnabled
        duckingEnabled = AppSettings.shared.volumeDuckingEnabled
        titlesEnabled = AppSettings.shared.titlesEnabled
        
        registNotifications()
        
        timelineDataSource = TimelineDataSource(viewController: self)
        collectionView.delegate = timelineDataSource
        collectionView.dataSource = timelineDataSource
        
        let backgroundView = UIView()
        let pattenImage = UIImage(named: "app_black_background")
        
//        let insetRect = CGRect(x: 2, y: 2, width: pattenImage?.size.width ?? 0 - 2, height: pattenImage?.size.width ?? 0 - 2)
        backgroundView.backgroundColor = UIColor(patternImage: pattenImage!) ?? UIColor.red
        collectionView.backgroundView = backgroundView
        
        playHeadView = PlayHeaderView(frame: view.bounds)
        view.addSubview(playHeadView!)
        
        
    }
    
    func synchronizePlayHead(with playerItem: AVPlayerItem) {
        playHeadView?.synchronize(with: playerItem)
    }
    
    func registNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleTransitionsEnabledState(_:)),
                                               name: TransitionsEnabledStateChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleVolumeFadesEnabledState(_:)),
                                               name: TransitionsEnabledStateChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleVolumeDuckingEnabledState(_:)),
                                               name: TransitionsEnabledStateChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleShowTitlesEnabledState(_:)),
                                               name: TransitionsEnabledStateChangeNotification, object: nil)
        
    }
    
    @objc
    func toggleTransitionsEnabledState(_ notification: Notification) {
        let state = notification.object as? Bool
        if transitionEnabled != state {
            transitionEnabled = state
            (collectionView.collectionViewLayout as! TimelineLayout).recordingAllowed = state == true ? false : true
            collectionView.reloadData()
        }
    }
    
    @objc
    func toggleVolumeFadesEnabledState(_ notification: Notification) {
        volumeFadesEnabled = notification.object as? Bool
        let items = timelineDataSource?.timelineItems?[MediaTrackType.music.rawValue]
        if items?.count ?? 0 > 0 {
            let model: TimelineItemViewModel = items?.last as! TimelineItemViewModel
            let item = model.timelineItem as! AudioItem
            item.volumnAutomation = volumeFadesEnabled == true ? buildVolumeFades(for: item) : nil
            
        }
        collectionView.reloadData()
    }
    
    @objc
    func toggleVolumeDuckingEnabledState(_ notification: Notification) {
        duckingEnabled = notification.object as? Bool
        collectionView.reloadData()
    }
    
    @objc
    func toggleShowTitlesEnabledState(_ notification: Notification) {
        titlesEnabled = notification.object as? Bool
        collectionView.reloadData()
    }
    
    func buildVolumeFades(for musicItem: AudioItem) -> [VolumeAutomation] {
        let fadeTime = CMTimeMake(value: 3, timescale: 1)
        var automation = [VolumeAutomation]()
        let startRange = CMTimeRangeMake(start: .zero, duration: fadeTime)
        
        automation.append(VolumeAutomation(timeRange: startRange, startVolume: 0, endVolume: 1))
        let voiceOvers = timelineDataSource?.timelineItems?[MediaTrackType.commontary.rawValue]
        for model in voiceOvers as! [TimelineItemViewModel] {
            let mediaItem = model.timelineItem
            let timeRange = mediaItem?.timeRange
            let halfTime = CMTimeMake(value: 1, timescale: 2)
            let startTime = CMTimeSubtract(mediaItem?.startTimeInTimeLine ?? .zero, halfTime)
            let endRangeStartTime = CMTimeAdd(mediaItem?.startTimeInTimeLine ?? .zero, timeRange?.duration ?? .zero)
            let endRange = CMTimeRangeMake(start: endRangeStartTime, duration: halfTime)
            
            automation.append(VolumeAutomation(timeRange: CMTimeRangeMake(start: startTime, duration: halfTime), startVolume: 1, endVolume: 0.2))
            automation.append(VolumeAutomation(timeRange: endRange, startVolume: 0.2, endVolume: 1))
            
        }
        
        let endRangeStartTime = CMTimeSubtract(musicItem.timeRange?.duration ?? .zero, fadeTime)
        let endRange = CMTimeRangeMake(start: endRangeStartTime, duration: fadeTime)
        automation.append(VolumeAutomation(timeRange: endRange, startVolume: 1, endVolume: 0))
        return automation
    }
    
    // MARK: Add Timeline item
    func clearTimeline() {
        collectionView.performBatchUpdates({[weak self] in
            var indexPaths = [IndexPath]()
            guard let items = self?.timelineDataSource?.timelineItems else {return}
            for (index, section) in items.enumerated() {
                for (j, _) in section.enumerated() {
                    indexPaths.append(IndexPath(item: j, section: index))
                }
            }
            self?.collectionView.deleteItems(at: indexPaths)
            self?.timelineDataSource?.resetTimeline()
        }) { [weak self] (result) in
            self?.collectionView.reloadData()
        }
    }
    
    func addTimelineItem(item: TimeLineItem, to track: MediaTrackType) {
        var items = timelineDataSource?.timelineItems?[track.rawValue]
        if track == .video {
            if items?.count == 3 {
                return
            }
            item.timeRange = CMTimeRangeMake(start: .zero, duration: CMTimeMake(value: 5, timescale: 1))
        } else if track == .music {
            if items?.count == 1 {
                return
            }
            item.timeRange = CMTimeRangeMake(start: .zero, duration: CMTimeMake(value: 15, timescale: 1))
        } else if track == .commontary {
            if items?.count == 1 {
                return
            }
        }
        let model = TimelineItemViewModel(timeline: item)
        
        var indexPaths = [IndexPath]()
        if track == .video && transitionEnabled == true && items?.count ?? 0 > 0 {
            let transition = VideoTransition.dissolveTransition(with: CMTime(seconds: 1, preferredTimescale: 2))
            items?.append(transition)
            let indexPath = IndexPath(item: (items?.count ?? 0 - 1), section: track.rawValue)
            indexPaths.append(indexPath)
        }
        
        if track == .music && volumeFadesEnabled == true {
            let audioItem = item as! AudioItem
            audioItem.volumnAutomation = buildVolumeFades(for: audioItem)
        }
        
        items?.append(model)
        let indexPath = IndexPath(item: items?.count ?? 0 - 1, section: track.rawValue)
        
        timelineDataSource?.timelineItems?[track.rawValue] = items!
        indexPaths.append(indexPath)
//        collectionView.insertItems(at: indexPaths)
        collectionView.reloadData()
    }
    
    func currentTimeLine() -> TimeLine {
        guard let items = timelineDataSource?.timelineItems else {return TimeLine()}
        return TimelineBuilder.buildTimeline(with: items as! [[TimelineItemViewModel]])
    }
    
    
}
