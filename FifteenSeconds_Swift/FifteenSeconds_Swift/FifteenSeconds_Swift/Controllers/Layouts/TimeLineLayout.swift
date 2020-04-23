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
    private var caculateLayout: [IndexPath: UICollectionViewLayoutAttributes]?
    private var initialLayout: [IndexPath: UICollectionViewLayoutAttributes]?
    
    private var updates: [Any]?
    private var scaleUnit: CGFloat?
    
    private var panDirection: PanDirection?
    
    private  var panGestureRecognize: UIPanGestureRecognizer?
    private  var longPressGestureRecognize: UILongPressGestureRecognizer?
    private  var tapGestureRecognize: UITapGestureRecognizer?
    
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
        var layoutDic = Dictionary<IndexPath,UICollectionViewLayoutAttributes>()
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
    
    override var collectionViewContentSize: CGSize {
        get {
            self.contentSize!
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttribute = [UICollectionViewLayoutAttributes]()
        caculateLayout?.forEach({ (indexpath, element) in
            if rect.intersects(element.frame) {
                allAttribute.append(element)
            }
        })
        return allAttribute
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return caculateLayout?[indexPath]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        panGestureRecognize = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        longPressGestureRecognize = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognize?.minimumPressDuration = 0.5
        tapGestureRecognize = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tapGestureRecognize?.numberOfTouchesRequired = 2
        
        collectionView?.gestureRecognizers?.forEach({ (ges) in
            if ges.isKind(of: UIPanGestureRecognizer.self) {
                ges.require(toFail: panGestureRecognize!)
            } else if ges.isKind(of: UILongPressGestureRecognizer.self) {
                ges.require(toFail: longPressGestureRecognize!)
            }
        })
        
        panGestureRecognize?.delegate = self
        longPressGestureRecognize?.delegate = self
        tapGestureRecognize?.delegate = self
        
        collectionView?.addGestureRecognizer(panGestureRecognize!)
        collectionView?.addGestureRecognizer(tapGestureRecognize!)
        collectionView?.addGestureRecognizer(longPressGestureRecognize!)
        
        
    }
    
    
    @objc
    func handleDrag(_ pan: UIPanGestureRecognizer) {
        
    }
    
    @objc
    func handleDoubleTap(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: collectionView)
        guard let indexPath = collectionView?.indexPathForItem(at: location) else { return }
        let delegate: UICollectionViewDelegateTimelineLayout = (collectionView?.delegate as! UICollectionViewDelegateTimelineLayout)
        delegate.collectionView(collectionView: collectionView!, willDeleteItemAt: indexPath)
        collectionView?.deleteItems(at: [indexPath])
    }
    
    @objc
    func handleLongPress(_ longPress: UITapGestureRecognizer) {
        if longPress.state == .began {
            dragMode = .move
            let location = longPress.location(in: collectionView)
            guard let indexPath = collectionView?.indexPathForItem(at: location) else {return}
            selectedIndexPath = indexPath
            collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            
            let cell = collectionView?.cellForItem(at: indexPath)
            cell?.isHighlighted = true
            dragableImageView = cell?.toImageView()
            dragableImageView?.frame = cell?.frame as! CGRect
            collectionView?.addSubview(dragableImageView!)
        }
        
        if longPress.state == .ended {
            let attributes = layoutAttributesForItem(at: selectedIndexPath!)
            UIView.animate(withDuration: 0.15, animations: {
                self.dragableImageView?.frame = (attributes?.frame)!
            }) { (result) in
                self.invalidateLayout()
                UIView.animate(withDuration: 0.2, animations: {
                    self.dragableImageView?.alpha = 0
                }) { (_) in
                    let cell = self.collectionView?.cellForItem(at: self.selectedIndexPath!)
                    cell?.isSelected = true
                    self.dragableImageView?.removeFromSuperview()
                    self.dragableImageView = nil
                }
                self.selectedIndexPath = nil
                self.dragMode = .trim
            }
        }
    }
    
}


class TimelineLayoutAttribute: UICollectionViewLayoutAttributes {
    var maxFrameWidth: CGFloat?
    var scaleUnit: CGFloat?
}

extension TimelineLayout: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
