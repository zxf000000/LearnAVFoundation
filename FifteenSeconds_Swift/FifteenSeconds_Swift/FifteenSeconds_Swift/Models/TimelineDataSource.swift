//
//  TimelineDataSource.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit


let VideoItemCollectionViewCellID        = "VideoItemCollectionViewCell"
let TransitionCollectionViewCellID    = "TransitionCollectionViewCell"
let TitleItemCollectionViewCellID        = "TitleItemCollectionViewCell"
let AudioItemCollectionViewCellID        = "AudioItemCollectionViewCell"

class TimelineDataSource:NSObject, UICollectionViewDataSource {
    
    var timelineItems: [Array<Any>]?
    var timelineViewController: TimeLineViewController!
    var transitionPopoverController: UIPopoverController!
    
    
    init(viewController: TimeLineViewController) {
        super.init()
        self.timelineViewController = viewController
        resetTimeline()
    }
    
    func clearTimeline() {
        timelineItems = [Array<TimelineItemViewModel>]()
    }
    
    func resetTimeline() {
        var items = [Array<Any>]()
        items.append([Any]())
        items.append([Any]())
        items.append([Any]())
        items.append([Any]())
        
        timelineItems = items
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return timelineItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timelineItems?[section].count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = cellID(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        cell.contentView.frame = cell.bounds
//        cell.contentView.autoresizingMask = (.flexibleWidth | .flexibleLeftMargin | .flexibleWidth | .flexibleRightMargin | .flexibleTopMargin | .flexibleHeight | .flexibleBottomMargin)
        if cellId == VideoItemCollectionViewCellID {
            configVideoCell(cell: cell as! VideoItemCollectionViewCell, indexPath: indexPath)
        } else if cellId == AudioItemCollectionViewCellID {
            configAudioCell(cell: cell as! AudioItemCollectionViewCell, indexPath: indexPath)
        } else if cellId == TitleItemCollectionViewCellID {
            configTitleCell(cell: cell as! TimeLineItemCollectionViewCell, indexPath: indexPath)
        } else if cellId == TransitionCollectionViewCellID {
            let transition = timelineItems?[indexPath.section][indexPath.item] as! VideoTransition
            let transCell = cell as! TransitionCollectionViewCell
            transCell.transitionButton.transitionType = transition.type
        }
        return cell
    }
    
    func configVideoCell(cell: VideoItemCollectionViewCell, indexPath: IndexPath) {
        guard let viewModel = timelineItems?[indexPath.section][indexPath.item] as? TimelineItemViewModel else {return}
        guard let item = viewModel.timelineItem as? VideoItem else {return}
        cell.maxTimeRagne = item.timeRange
        cell.itemView.titleLabel.text = item.title ?? ""
        cell.itemView.backgroundColor = UIColor(red: 0.523, green: 0.641, blue: 0.851, alpha: 1)
    }
    
    func configAudioCell(cell: AudioItemCollectionViewCell, indexPath: IndexPath) {
        
        guard let viewModel = timelineItems?[indexPath.section][indexPath.item] as? TimelineItemViewModel else {return}
        guard let item = viewModel.timelineItem as? AudioItem else {return}
        
        if indexPath.section == MediaTrackType.music.rawValue {
            
            cell.audioAutomationView.audioRamps = item.volumnAutomation
            cell.audioAutomationView.duration = item.timeRange?.duration
            cell.itemView.backgroundColor = UIColor(red: 0.361, green: 0.762, blue: 0.366, alpha: 1)
        } else {
            cell.audioAutomationView.audioRamps = nil
            cell.audioAutomationView.duration = .zero
            cell.itemView.backgroundColor = UIColor(red: 0.992, green: 0.785, blue: 0.106, alpha: 1)
        }
   }
    
    func configTitleCell(cell: TimeLineItemCollectionViewCell, indexPath: IndexPath) {
        guard let viewModel = timelineItems?[indexPath.section][indexPath.item] as? TimelineItemViewModel else {return}
        
        guard let layer: CompositionLayer = viewModel.timelineItem as? CompositionLayer else {return}
        cell.itemView.titleLabel.text = layer.identifier
        cell.itemView.backgroundColor = UIColor(red: 0.741, green: 0.556, blue: 1.000, alpha: 1)
        
    }
    func cellID(for indexPath: IndexPath) -> String {
        
        if timelineViewController.transitionEnabled == true && indexPath.section == 0 {
            return indexPath.item % 2 == 0 ? VideoItemCollectionViewCellID : TransitionCollectionViewCellID
        } else if indexPath.section == 0 {
            return VideoItemCollectionViewCellID
        } else if indexPath.section == 1 {
            return TitleItemCollectionViewCellID
        } else if indexPath.section == 2 || indexPath.section == 3 {
            return AudioItemCollectionViewCellID
        }
        return ""
    }
 
}

extension TimelineDataSource: UICollectionViewDelegateTimelineLayout {
    
    func collectionView(collectionView: UICollectionView, willDeleteItemAt indexPath: IndexPath) {
        var items = timelineItems?[indexPath.section]
        items?.remove(at: indexPath.item)
        timelineItems?[indexPath.section] = items!
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && timelineViewController.transitionEnabled == false
    }
    
    func collectionView(collectionView: UICollectionView, didMoveMediaItemAt indexPath: IndexPath, toIndexPath: IndexPath) {
        var items = timelineItems?[indexPath.section]
        if indexPath == toIndexPath {
            assert(false, "Attempting to make an invalid move")
        }
        // exchange
        items?.xf_exchangeElement(from: indexPath.item, to: toIndexPath.item)
        timelineItems?[indexPath.section] = items!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = timelineItems?[indexPath.section][indexPath.item] as? VideoTransition else {return}
        configTransition(transition: viewModel, at: indexPath)
    }
    
    func configTransition(transition: VideoTransition, at indexPath: IndexPath) {
        let transitionViewController = TransitionViewController(transition: transition)
        transitionViewController.delegate = self
        transitionPopoverController = UIPopoverController(contentViewController: transitionViewController)
        let cell = timelineViewController.collectionView.cellForItem(at: indexPath)
        transitionPopoverController.present(from: cell?.frame ?? .zero,
                                            in: timelineViewController.view,
                                            permittedArrowDirections: UIPopoverArrowDirection.down,
                                            animated: true)
        
    }
    
    func collectionView(collectionView: UICollectionView, widthForItemAt indexPath: IndexPath) -> CGFloat {
        if timelineViewController.transitionEnabled == true && indexPath.section == 0 && indexPath.item > 0 {
            if indexPath.item % 2 != 0 {
                return 32
            }
        }
        guard let viewModel = timelineItems?[indexPath.section][indexPath.item] as? TimelineItemViewModel else {return 0}
        return viewModel.widthInTimeline!
    }
    
    func collectionView(collectionView: UICollectionView, positionForItemAt indexPath: IndexPath) -> CGPoint {
        if indexPath.section == MediaTrackType.commontary.rawValue || indexPath.section == MediaTrackType.title.rawValue {
            guard let viewModel = timelineItems?[indexPath.section][indexPath.item] as? TimelineItemViewModel else {return .zero}
            return viewModel.positionInTimeline ?? .zero
        }
        return .zero
    }
    
    func collectionView(collectionView: UICollectionView, didAdjustTo width: CGFloat, forItemAt indexPath: IndexPath) {
        guard let viewModel = timelineItems?[indexPath.section][indexPath.item] as? TimelineItemViewModel else {return}
        
        if width < viewModel.maxWidthInTimeline ?? 0 {
            viewModel.maxWidthInTimeline = width
        }
    }
    func collectionView(collectionView: UICollectionView, didAdjustTo position: CGPoint, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == MediaTrackType.commontary.rawValue || indexPath.section == MediaTrackType.title.rawValue {
            guard let viewModel = timelineItems?[indexPath.section][indexPath.item] as? TimelineItemViewModel else {return}
            viewModel.positionInTimeline = position
            viewModel.udpateTimelineItem()
            timelineViewController.collectionView.reloadData()
        }
    }
    
    func collectionView(theCollectionView: UICollectionView, layout: UICollectionViewLayout, itemAtIndexPath: IndexPath, shouldMove toIndexPath: IndexPath) -> Bool {
        return itemAtIndexPath.section == toIndexPath.section
    }
}

extension TimelineDataSource: TransitionViewControllerDelegate {
    func transitionSelected() {
        transitionPopoverController.dismiss(animated: true)
        transitionPopoverController = nil
        timelineViewController.collectionView.reloadData()
    }
}
