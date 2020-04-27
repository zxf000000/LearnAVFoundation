//
//  ViewController.swift
//  VideoTransitionDemo
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {

    var videoDuration = CMTimeMake(value: 5, timescale: 1)
    
    var player: AVPlayer!
    
    var slider: UISlider!
    
    var playButton: UIButton!
    
    var compositionButton: UIButton!
    
    var compositionResultItem: AVPlayerItem!
    
    var videoComposition: AVMutableVideoComposition!
    
    var debugView: APLCompositionDebugView!
    
    var assetA: AVAsset!
    var assetB: AVAsset!
    var assetC: AVAsset!
    var playerItemA: AVPlayerItem!
    var playerItemB: AVPlayerItem!
    var playerItemC: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    
    
    var assets: [AVAsset]!
    
    var timer: Timer!
    
    var composition: AVMutableComposition!
    

    var videoNames = [
        "test.mp4",
        "test1.mp4",
        "04_quasar.mp4"
    ]

    var segment: UISegmentedControl!


    override func viewDidLoad() {
        super.viewDidLoad()


        setupView()

        setupPlayer()
    }

    @objc
    func segmentDidChange() {
        switch segment.selectedSegmentIndex {
        case 0:
            player.replaceCurrentItem(with: playerItemA)
        case 1:
            player.replaceCurrentItem(with: playerItemB)
        case 2:
            player.replaceCurrentItem(with: playerItemC)
        default:
            break
        }
    }
    
    @objc
    func sliderValueChange() {
        player.pause()
        
        let progress = slider.value
        let seconds = CMTimeGetSeconds(player.currentItem?.duration ?? .zero)
        let currentSecond = Double(progress) * seconds
        player.currentItem?.seek(to: CMTimeMake(value: Int64(currentSecond), timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { (_) in
            
        })
    }
    
    @objc
    func tapCompositinButton() {
        // 开始合成
        composition = AVMutableComposition()
        assets = [assetA, assetB]
        
        buildCompositionTracks()
        
        let videoComposition = buildVideoComposition()

        compositionResultItem = AVPlayerItem(asset: composition, automaticallyLoadedAssetKeys: ["tracks","duration","commonMetadata"])
        compositionResultItem.videoComposition = videoComposition
        compositionResultItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player = AVPlayer(playerItem: compositionResultItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: segment.frame.maxY + 20, width: view.bounds.width, height: 300)
        view.layer.addSublayer(playerLayer)
        
//        debugView.player = player
//        debugView.synchronize(to: composition, videoComposition: videoComposition, audioMix: nil)
//
//        debugView.frame = CGRect(x: 0, y: view.bounds.height - 350, width: view.bounds.width, height: 300)
//
//
//        debugView.setNeedsDisplay()
//
        
        
//        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 4), queue: DispatchQueue.main) { (time) in
//            print(CMTimeGetSeconds(time))
//        }
        
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/\(Int(Date().timeIntervalSince1970)).mp4") else {return}
        let url = URL(fileURLWithPath: path)
        exportSession?.videoComposition = videoComposition
        exportSession?.outputURL = url
        exportSession?.outputFileType = .mp4
        exportSession?.exportAsynchronously(completionHandler: {
            print(path)

        })
                
    }
    
    func buildVideoComposition() -> AVVideoComposition {
        let videoComposition = AVVideoComposition(propertiesOf: composition)
        let transitionInstructions = transitionInstructionsIn(videoComposition: videoComposition)
        
        for instruction in transitionInstructions {
            let timeRange = instruction.compositionInstruction.timeRange
            let fromLayer = instruction.fromLayerInstruction
            let toLayer = instruction.toLayerInstruction
                          // 2
            
            let width = videoComposition.renderSize.width
            let identityTransform = CGAffineTransform.identity
            let firstTransition = CGAffineTransform(translationX: -width, y: 0)
            let secondTransform = CGAffineTransform(translationX: width, y: 0)
            
            fromLayer?.setTransformRamp(fromStart: identityTransform, toEnd: firstTransition, timeRange: timeRange)
            toLayer?.setTransformRamp(fromStart: secondTransform, toEnd: identityTransform, timeRange: timeRange)
            
            instruction.compositionInstruction.layerInstructions = [fromLayer!, toLayer!]
        }
        
        
        return videoComposition
    }
    
    func transitionInstructionsIn(videoComposition: AVVideoComposition) -> [TransitionInstructions] {
        var transitionInstructions = [TransitionInstructions]()
        var layerInstructionIndex = 1
        let compositionInstructions = videoComposition.instructions as! [AVMutableVideoCompositionInstruction]
        for vci in compositionInstructions {
            if vci.layerInstructions.count == 2 {
                let transition = TransitionInstructions()
                transition.compositionInstruction = vci
                transition.fromLayerInstruction = vci.layerInstructions[1-layerInstructionIndex] as? AVMutableVideoCompositionLayerInstruction
                transition.toLayerInstruction = vci.layerInstructions[layerInstructionIndex] as? AVMutableVideoCompositionLayerInstruction
                
                transitionInstructions.append(transition)
                layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1;
            } else {
            }
        }
        return transitionInstructions
    }
    
    func buildCompositionTracks() {
        let trackID = kCMPersistentTrackID_Invalid
        let compositionTrackA = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackID)
        let compositionTrackB = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackID)
        let videoTracks = [compositionTrackA, compositionTrackB]
        var cursorTime = CMTime.zero;
        let transitionDuration = CMTimeMake(value: 1, timescale: 1);
        
        for i in 0..<assets.count {
            let trackIndex = i % 2
            let asset = assets[i]
            let currentTrack = videoTracks[trackIndex]
                        
            let assetTrack = asset.tracks(withMediaType: .video).first
            
            let assetTimeRange = CMTimeRangeMake(start: .zero, duration: videoDuration)
            try! currentTrack?.insertTimeRange(assetTimeRange, of: assetTrack!, at: cursorTime)
            
//            if cursorTime != .zero {
//                currentTrack?.insertEmptyTimeRange(CMTimeRangeMake(start: .zero, duration: CMTimeSubtract(cursorTime, <#T##rhs: CMTime##CMTime#>)))
//            }
            
            cursorTime = CMTimeAdd(cursorTime, assetTimeRange.duration)
            cursorTime = CMTimeSubtract(cursorTime, transitionDuration)
        }
        
        printTimeRanges(timeRanges: [(compositionTrackA?.timeRange)!, (compositionTrackB?.timeRange)!])
        
        
    }

    @objc
    func tapPlayButton() {
        player.play()
    }
    
    func printTimeRanges(timeRanges: [CMTimeRange]) {
        for timerange in timeRanges {
            print("begin: \(CMTimeGetSeconds(timerange.start)) end: \(CMTimeGetSeconds(timerange.end))")
        }
    }
    
    func setupView() {
        segment = UISegmentedControl(items: ["AssetA", "AssetB", "AssetC"])
        segment.frame = CGRect(x: 50, y: 100, width: view.bounds.width - 100, height: 50)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        view.addSubview(segment)

        slider = UISlider(frame: CGRect(x: 30, y: segment.frame.maxY + 20 + 300, width: view.bounds.width - 60, height: 30))
        slider.minimumValue = 0
        slider.maximumValue = 1
        view.addSubview(slider)
        
        slider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        
        compositionButton = UIButton(type: .custom)
        compositionButton.setTitle("合成", for: .normal)
        compositionButton.setTitleColor(UIColor.systemPurple, for: .normal)
        compositionButton.addTarget(self, action: #selector(tapCompositinButton), for: .touchUpInside)
        compositionButton.frame = CGRect(x: 100, y: slider.frame.maxY + 20, width: view.bounds.width - 200, height: 40)
        compositionButton.setBackgroundImage(image(with: .red), for: .normal)
        view.addSubview(compositionButton)
        
        playButton = UIButton()
        playButton.setTitle("play", for: .normal)
        playButton.setBackgroundImage(image(with: .blue), for: .normal)
        view.addSubview(playButton)
        playButton.frame = CGRect(x: 100, y: compositionButton.frame.maxY + 20, width: view.bounds.width - 200, height: 40)
        playButton.addTarget(self, action: #selector(tapPlayButton), for: .touchUpInside)
        
        debugView = APLCompositionDebugView()
        debugView.frame = CGRect(x: 0, y: view.bounds.height - 350, width: view.bounds.width, height: 300)
        view.addSubview(debugView)
    }
    
    

    func setupPlayer() {
        assetA = AVURLAsset(url: url(for: 0), options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        assetB = AVURLAsset(url: url(for: 1), options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        assetC = AVURLAsset(url: url(for: 2), options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        assetA.loadValuesAsynchronously(forKeys: ["tracks","duration","commonMetadata"]) {
            print("complete 111")
        }
        
        assetB.loadValuesAsynchronously(forKeys: ["tracks","duration","commonMetadata"]) {
            print("complete 222")
        }
        
        assetC.loadValuesAsynchronously(forKeys: ["tracks","duration","commonMetadata"]) {
            print("complete 333")
        }
        
//        playerItemA = AVPlayerItem(asset: assetA)
//        playerItemB = AVPlayerItem(asset: assetB)
//        playerItemC = AVPlayerItem(asset: assetC)
//        player = AVPlayer(playerItem: playerItemA)
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = CGRect(x: 0, y: segment.frame.maxY + 20, width: view.bounds.width, height: 300)
//        view.layer.addSublayer(playerLayer)
//
//        playerItemA.addObserver(self, forKeyPath: "status", options: .new, context: nil)
//        playerItemB.addObserver(self, forKeyPath: "status", options: .new, context: nil)
//        playerItemC.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let playerItem: AVPlayerItem = (player.currentItem)!
        if playerItem.status == AVPlayerItem.Status.readyToPlay {
            player.play()
        }
        
        print(playerItem.status.rawValue)
        
    }

    func url(for index: Int) -> URL {
        let name = videoNames[index]
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {return URL(fileURLWithPath: "")}
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    func image(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }

}
