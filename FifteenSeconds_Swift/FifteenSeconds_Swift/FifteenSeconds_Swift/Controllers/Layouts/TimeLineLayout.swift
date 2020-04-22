//
//  TimeLineLayout.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

protocol UICollectionViewDelegateTimelineLayout: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, willDeleteItemAt indexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, didMoveMediaItemAt indexPath: IndexPath, toIndexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, didAdjustTo width: CGFloat, forItemAt indexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, didAdjustTo position: CGPoint, forItemAt indexPath: IndexPath)
    func collectionView(collectionView: UICollectionView, widthForItemAt indexPath: IndexPath) -> CGFloat
    func collectionView(collectionView: UICollectionView, positionForItemAt indexPath: IndexPath) -> CGPoint
}

enum PanDirection {
    case right
    case left
}

enum DragMode {
    case none
    case move
    case trim
}

let DEFAULT_TRACK_HEIGHT: CGFloat = 80.0
let DEFAULT_CLIP_SPACING: CGFloat = 0.0
let TRANSITION_CONTROL_HW: CGFloat = 32.0
let VERTICAL_PADDING: CGFloat = 4.0
let DEFAULT_INSETS = UIEdgeInsets(top: 4, left: 5, bottom: 5, right: 5)


class TimelineLayout: UICollectionViewLayout {
    var trackHeight: CGFloat? {
        didSet{
            invalidateLayout()
        }
    }
    var clipSpacing: CGFloat? {
        didSet {
            invalidateLayout()
        }
    }
    var trackInsets: UIEdgeInsets? {
        didSet {
            invalidateLayout()
        }
    }
    var recordingAllowed: Bool = false {
        didSet {
            panGestureRecognize?.isEnabled = recordingAllowed
            longPressGestureRecognize?.isEnabled = recordingAllowed
            
            invalidateLayout()
        }
    }
    
    
    private var contentSize: CGSize?
    private var caculateLayout: [IndexPath: Any]?
    private var initialLayout: [IndexPath: Any]?
    
    private var updates: [Any]?
    private var scaleUnit: CGFloat?
    
    private var panDirection: PanDirection?
    
    private weak var panGestureRecognize: UIPanGestureRecognizer?
    private weak var longPressGestureRecognize: UILongPressGestureRecognizer?
    private weak var tapGestureRecognize: UITapGestureRecognizer?
    
    private var selectedIndexPath: IndexPath?
    private var dragableImageView: UIImageView?
    
    private var swapInProgress: Bool?
    private var dragMode: DragMode?
    
    private var trimming: Bool?
    
    override init() {
        super.init()
        setup()
    }
    
    
    func setup() {
        trackInsets = DEFAULT_INSETS
        trackHeight = DEFAULT_TRACK_HEIGHT
        clipSpacing = DEFAULT_CLIP_SPACING
        recordingAllowed = true
        dragMode = .trim
    }
    
    override class var layoutAttributesClass: AnyClass {
        return TimelineLayoutAttribute.self
    }
    
    override func prepare() {
        var layoutDic = Dictionary<IndexPath,Any>()
        var xPos = trackInsets?.left
        var yPos: CGFloat = 0
        let delegate = collectionView?.delegate as? UICollectionViewDelegateTimelineLayout
        var maxTrackWidth: CGFloat = 0.0;

        let trackCount = collectionView?.numberOfSections
        for track in 0..<trackCount! {
            let itemCount = collectionView?.numberOfItems(inSection: track)
            for item in 0..<itemCount! {
                let indexPath = IndexPath(item: item, section: track)
                var attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath) as! TimelineLayoutAttribute
                let width = delegate?.collectionView(collectionView: collectionView!, widthForItemAt: indexPath)
                let position = delegate?.collectionView(collectionView: collectionView!, positionForItemAt: indexPath)
                if position?.x ?? 0 > 0 {
                    xPos = position?.x
                }
                attributes.frame = CGRect(x: xPos ?? 0, y: yPos + (trackInsets?.top)!, width: width!, height: trackHeight! - (trackInsets?.bottom)!)
                if width == TRANSITION_CONTROL_HW {
                    var rect = attributes.frame
                    rect.origin.y += (rect.size.height - TRANSITION_CONTROL_HW) / 2 + VERTICAL_PADDING
                    rect.origin.x -= TRANSITION_CONTROL_HW / 2
                    attributes.frame = rect
                    attributes.zIndex = 1
                }
                if selectedIndexPath == indexPath {
                    attributes.isHidden = true
                }
                layoutDic[indexPath] = attributes
                if width != TRANSITION_CONTROL_HW {
                    xPos! += width! + clipSpacing!
                }
            }
            if xPos! > maxTrackWidth {
                maxTrackWidth = xPos!
            }
            xPos = trackInsets?.left
            yPos = trackHeight!
        }
        self.contentSize = CGSize(width: maxTrackWidth, height: CGFloat(trackCount!) * self.trackHeight!);
        caculateLayout = layoutDic

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}


class TimelineLayoutAttribute: UICollectionViewLayoutAttributes {
    var maxFrameWidth: CGFloat?
    var scaleUnit: CGFloat?
}
