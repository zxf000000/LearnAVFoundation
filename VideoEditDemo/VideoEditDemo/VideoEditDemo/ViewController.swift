//
//  ViewController.swift
//  VideoEditDemo
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {

    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var playerItem: AVPlayerItem!

    var resultAsset: AVAsset!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        editAsset()
        setupPlayer()
        saveToAlbum()

    }


    /// 重新编辑
    func editAsset() {
        guard let url1 = Bundle.main.url(forResource: "lx.mp4", withExtension: nil),
              let url2 = Bundle.main.url(forResource: "wmsh.mp4", withExtension: nil),
              let url3 = Bundle.main.url(forResource: "xfyy.mp4", withExtension: nil) else {return}
        let asset1 = AVURLAsset(url: url1)
        let asset2 = AVURLAsset(url: url2)
        let asset3 = AVURLAsset(url: url3)
        let compostion = AVMutableComposition()
        // video track
        let videoTrack = compostion.addMutableTrack(withMediaType: .video,
                                                    preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = compostion.addMutableTrack(withMediaType: .audio,
                                                    preferredTrackID: kCMPersistentTrackID_Invalid)

        var cursorTime = CMTime.zero
        let videoDuration = CMTime(seconds: 5, preferredTimescale: 1)
        let videoTimeRange = CMTimeRange(start: .zero, duration: videoDuration)

        var assetTrack: AVAssetTrack?
        assetTrack = asset1.tracks(withMediaType: .video).first
        // 从视频轨道中选取timeRange的段落添加到videoTrack中
        try! videoTrack?.insertTimeRange(videoTimeRange, of: assetTrack!, at: cursorTime)
        //添加第二段视频
        cursorTime = CMTimeAdd(cursorTime, videoDuration)
        assetTrack = asset2.tracks(withMediaType: .video).first
        try! videoTrack?.insertTimeRange(videoTimeRange, of: assetTrack!, at: cursorTime)
        // 添加音频到两断时间
        cursorTime = .zero
        let audioDuration = compostion.duration
        let audioTimeRange = CMTimeRangeMake(start: .zero, duration: audioDuration)
        assetTrack = asset3.tracks(withMediaType: .audio).first
        try! audioTrack?.insertTimeRange(audioTimeRange, of: assetTrack!, at: cursorTime)

        resultAsset = compostion
    }

    /// 获取asset信息
    func getValuesTest() {
        guard let url1 = Bundle.main.url(forResource: "lx.mp4", withExtension: nil),
              let url2 = Bundle.main.url(forResource: "wmsh.mp4", withExtension: nil) else {return}
        /// 这个key确保载入asset 信息的时候可以准确计算时长和时间信息
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let keys = ["tracks", "duration", "commonMetadata"]
        let asset = AVURLAsset(url: url1, options: options)
        asset.loadValuesAsynchronously(forKeys: keys) {
            print(asset.tracks)
            print(asset.duration)
        }
    }


    func setupPlayer() {
        playerItem = AVPlayerItem(asset: resultAsset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 200, width: view.bounds.width, height: 300)
        view.layer.addSublayer(playerLayer)

        playerItem.addObserver(self, forKeyPath: "status", context: nil)
    }


    override func observeValue(forKeyPath keyPath: String?,
                      of object: Any?,
                      change: [NSKeyValueChangeKey : Any]?,
                      context: UnsafeMutableRawPointer?) {
        switch  playerItem.status {
        case .readyToPlay:
            player.play()
        default:
            break
        }
    }
    
    func saveToAlbum() {
        
        let session = AVAssetExportSession(asset: resultAsset, presetName: AVAssetExportPresetPassthrough)
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/\(Int(Date().timeIntervalSince1970)).mov")
        let url = URL(fileURLWithPath: path!, isDirectory: false)
        session?.outputURL = url
        session?.outputFileType = .mov
        
        
        session?.exportAsynchronously(completionHandler: {
            if session?.status == AVAssetExportSession.Status.completed {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { (result, error) in
                    if result == true {
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                }
            }
        })
        

    }

    
    


}
