//
//  PlayerViewController.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import AVKit

let VIDEO_SIZE = CGSize(width: 1280,height: 720)


class PlayerViewController: UIViewController  {
    
    var asset: AVAsset?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackView: PlaybackView!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var exporting: Bool = false {
        didSet {
            if exporting == true {
                progressView.progress = 0
                progressView.alpha = 0
                view.bringSubviewToFront(progressView)
                UIView.animate(withDuration: 0.4) {
                    self.progressView.alpha = 1
                }
            } else {
                UIView.animate(withDuration: 0.4, animations: {
                    self.progressView.alpha = 0
                }) { (_) in
                    self.view.bringSubviewToFront(self.progressView)
                }
            }
        }
    }
    
    var playbackMediator: PlaybackMediator?
    
    
    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?
    private var scrubing: Bool = false
    private var lastplaybackRate: Float?
    private var autoplayContent: Bool = false
    private var readyForDisplay: Bool = false
    private var titleView: UIView?
    
    private var mutingAudioMix: AVAudioMix?
    private var lastAudioMix: AVAudioMix?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoplayContent = true
        view.bringSubviewToFront(indicatorView)
    }
    
    func loadInitialPlayerItem(item: AVPlayerItem) {
        titleView?.removeFromSuperview()
        autoplayContent = true
        player?.rate = 0
        playerItem = item
        playButton.isSelected = true
        if playerItem != nil {
            prepareToPlay()
        }
    }
    
    func play(item: AVPlayerItem) {
        autoplayContent = true
        player?.rate = 0
        playerItem = item
        playButton.isSelected = true
        
        prepareToPlay()
        
        
    }
    
    func prepareToPlay() {
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
            playbackView.player = player
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if playerItem?.status == AVPlayerItem.Status.readyToPlay {
                if autoplayContent {
                    player?.play()
                } else {
                    stopPlayback()
                }
                playerItem?.removeObserver(self, forKeyPath: "status")
                prepareAudioMix()
                if readyForDisplay == false {
                    UIView.animate(withDuration: 0.35, animations: {
                        self.indicatorView.alpha = 0
                    }) { (_) in
                        self.view.sendSubviewToBack(self.indicatorView)
                    }
                }
            }
        }
    }
    
    func stopPlayback() {
        player?.rate = 0
        player?.seek(to: .zero)
        playButton.isSelected = false
    }

    @IBAction func play(_ sender: UIButton) {
        if player?.rate == 1 {
            player?.rate = 0
            sender.isSelected = false
        } else {
            playbackMediator?.prepareTimelineForPlayback()
            sender.isSelected = true
        }
        
    }
    
    func beginRewinding() {
        lastAudioMix = playerItem?.audioMix
        lastplaybackRate = player?.rate
        playerItem?.audioMix = mutingAudioMix
        player?.rate = -2
    }
    func endRewinding() {
        playerItem?.audioMix = lastAudioMix
        player?.rate = lastplaybackRate ?? 0
    }
    
    func beginFastForwarding() {
        lastAudioMix = playerItem?.audioMix
        lastplaybackRate = player?.rate
        playerItem?.audioMix = mutingAudioMix
        player?.rate = 2
    }
    
    func endFastForwording() {
        playerItem?.audioMix = lastAudioMix
        player?.rate = lastplaybackRate ?? 0
    }
    
    func addSynchronizeLayer(syncLayer: AVSynchronizedLayer) {
        titleView?.removeFromSuperview()
        titleView = UIView(frame: .zero)
        titleView?.layer.addSublayer(syncLayer)
        
        let scale = fminf(Float(view.bounds.width / VIDEO_SIZE.width), Float(view.bounds.height / VIDEO_SIZE.height))
        let videoRect = AVMakeRect(aspectRatio: VIDEO_SIZE, insideRect: view.bounds)
        titleView?.center = CGPoint(x: videoRect.midX, y: videoRect.midY)
        titleView?.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        view.addSubview(titleView!)
    }
    func playerItemDidReachEnd() {
        stopPlayback()
        NotificationCenter.default.post(name: PlaybackEndedNotification, object: nil)
    }
    
    
    
    func prepareAudioMix() {
        mutingAudioMix = buildAudioMixFor(playerItem: playerItem!, level: 0.05)
        if playerItem?.audioMix == nil {
            playerItem?.audioMix = buildAudioMixFor(playerItem: playerItem!, level: 1)
        }
    }
    
    func buildAudioMixFor(playerItem: AVPlayerItem, level: CGFloat) -> AVAudioMix {
        var parames = [AVAudioMixInputParameters]()
        for track in playerItem.tracks {
            if track.assetTrack?.mediaType == .audio {
                let audioMixParameters = AVMutableAudioMixInputParameters(track: track.assetTrack)
                audioMixParameters.setVolume(Float(level), at: .zero)
                parames.append(audioMixParameters)
            }
        }
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = parames
        return audioMix
    }
    
    
    @IBAction func export(_ sender: Any) {
    }
    
    
}
