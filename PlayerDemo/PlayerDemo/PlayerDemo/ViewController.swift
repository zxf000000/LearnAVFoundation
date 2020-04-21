//
//  ViewController.swift
//  PlayerDemo
//
//  Created by 壹九科技1 on 2020/4/6.
//  Copyright © 2020 YJKJ. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreServices


class ViewController: UIViewController {

    var player: AVPlayer!
    var slider: UISlider!
    
    var duration: CMTime!
    
    var asset: AVURLAsset!
    
    var priviewView: UIImageView!
    
    var assetReader: AVAssetReader!
    var assetWriter: AVAssetWriter!
    
    var exportSession: AVAssetExportSession!
    
    var imagePicker = UIImagePickerController()
    
    var progressBar = UIProgressView()
    
    var imageGenerate: AVAssetImageGenerator!
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            switch player.status {
            case .readyToPlay:
                duration = asset.duration
                player.play()
            default:
                break
            }
        } else {
            progressBar.progress = exportSession.progress

        }
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        setup()
        
        loadAudioInfo()
        
        
        let waveView = WaveFormView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.size.height))
        waveView.backgroundColor = .black
        view.addSubview(waveView)
        
        waveView.asset = asset
    }
    
    func loadAudioInfo() {
        let path = Bundle.main.path(forResource: "test1", ofType: "mp4")
        
        let url = URL(fileURLWithPath: path ?? "")
        
        loadMovie(url)
    }
    
    func setup() {
        progressBar.frame = CGRect(x: 0, y: 88, width: view.bounds.size.width, height: 30)
         progressBar.tintColor = .blue
         view.addSubview(progressBar)

         let path = Bundle.main.path(forResource: "test", ofType: "mp4")
         
         let url = URL(fileURLWithPath: path ?? "")
         
         loadMovie(url)

//         export { (exportUrl) in
//             print(exportUrl)
//             self.loadMovie(exportUrl)
//             self.createPlayer()
//         }
//
        
//        priviewView = UIImageView()
//        view.addSubview(priviewView)
//        imageGenerate = AVAssetImageGenerator(asset: asset)
//        imageGenerate.maximumSize = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
//        imageGenerate.requestedTimeToleranceAfter = .zero
//        imageGenerate.requestedTimeToleranceBefore = .zero
        createPlayer()

    }

    
    func export2(_ exportComplete: @escaping (URL) -> Void) {
        exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        exportSession?.outputURL = outputURL()
        exportSession?.outputFileType = .mp4
        exportSession?.addObserver(self, forKeyPath: "progress", options: .new, context: nil)
        exportSession?.exportAsynchronously(completionHandler: {
            switch self.exportSession?.status {
            case .cancelled:
                print("export cancelled")
            case .failed:
                print("export failed")
            case .completed:
                print("export completed")
                DispatchQueue.main.async {
                    exportComplete((self.exportSession?.outputURL)!)
                }
            case .none:
                break
            case .unknown:
                break
            case .some(.waiting):
                break
            case .some(.exporting):
                break
            case .some(_):
                break
            }
        })
    }
    
    
    func export(_ exportComplete: @escaping (URL) -> Void) {

        do {
            assetReader = try AVAssetReader(asset: asset)
            
            let track = asset.tracks(withMediaType: .video).first
            let settings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32ARGB]
            
            let trackOutput = AVAssetReaderTrackOutput(track: track!, outputSettings: settings as [String : Any])
            
            if assetReader.canAdd(trackOutput) {
                assetReader.add(trackOutput)
            }
            assetReader.startReading()
            
            /// 配置writer
            assetWriter = try AVAssetWriter(outputURL: outputURL(), fileType: .mp4)
            
            
            
            let writerOutputSettings = [AVVideoCodecKey: AVVideoCodecType.h264,
                                        AVVideoWidthKey: 1280,
                                        AVVideoHeightKey: 720,
                                        AVVideoCompressionPropertiesKey: [
                                            AVVideoMaxKeyFrameIntervalKey: 1,
                                            AVVideoAverageBitRateKey: 10500000,
                                            AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel]] as [String : Any]
            
            let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: writerOutputSettings)
            assetWriter.add(writerInput)
            assetWriter.startWriting()
            let queue = DispatchQueue(label: "com.assetExampe.www")
            assetWriter.startSession(atSourceTime: .zero)
            writerInput.requestMediaDataWhenReady(on: queue) {
                var complete = false
                while writerInput.isReadyForMoreMediaData == true && !complete {
                    let sampleBuffer = trackOutput.copyNextSampleBuffer()
                    if sampleBuffer != nil {
                        let result = writerInput.append(sampleBuffer!)
                        complete = !result
                        print("---")
                    } else {
                        writerInput.markAsFinished()
                        complete = true
                    }
                }
                if complete == true {
                    self.assetWriter.finishWriting {
                        let status = self.assetWriter.status
                        if status == .completed {
                            /// 成功
                            DispatchQueue.main.async {
                                exportComplete(self.assetWriter.outputURL)
                            }
                        } else {
                            print("导出失败")
                        }
                    }
                }
            }
        } catch {
                
            
        }
    }
    
    func outputURL() -> URL {
        let path = docPath().appending("/\(Date().timeIntervalSince1970).mp4")
        let url = URL(fileURLWithPath: path)
        
        print("path: \n  \(path)")
        
        return url
    }
    
    func docPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    func createPlayer() {
        let item = AVPlayerItem(asset: asset)

        player = AVPlayer(playerItem: item)

        player.addObserver(self, forKeyPath: "status", options: .new, context: nil)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 100, width: view.bounds.size.width, height: 300)

        view.layer.addSublayer(playerLayer)
        
//        priviewView.frame = CGRect(x: 0, y: 100, width: view.bounds.size.width, height: 300)
//        priviewView.contentMode = .scaleAspectFit
//
        slider = UISlider(frame: CGRect(x: 30, y: 450, width: view.bounds.size.width - 60, height: 40))
        slider.maximumValue = 1
        slider.minimumValue = 0
        view.addSubview(slider)
        
        slider.addTarget(self, action: #selector(sliderSlide), for: .valueChanged)
    }
    
    func loadMovie(_ url: URL) {
        asset = AVURLAsset(url: url)
    }
    
    @objc
    func sliderSlide() {
        let second = Double(self.slider.value) * CMTimeGetSeconds(duration)
                
        print("请求时间    \(second)")
//        var time = CMTime.zero
//        DispatchQueue.global().async {
//            do {
//                let image = try self.imageGenerate.copyCGImage(at: CMTime(seconds: second, preferredTimescale: 1), actualTime: &time)
//                DispatchQueue.main.async {
//                    print("实际时间 ------     \(CMTimeGetSeconds(time))")
//                    self.priviewView.image = UIImage(cgImage: image)
//
//                }
//
//            } catch {
//
//            }
//        }
        
//        imageGenerate.cancelAllCGImageGeneration()
//
//        imageGenerate.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTime(seconds: second, preferredTimescale: 1))]) { (time, image, time1, result, error) in
//
//            print("图片时间   \(CMTimeGetSeconds(time1))")
//
//            guard let image1 = image else {return}
//
//            DispatchQueue.main.async {
//                self.priviewView.image = UIImage(cgImage: image1)
//            }
//        }

        
        
        player.seek(to: CMTime(seconds: second * 1000, preferredTimescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero) { (flag) in
            print(flag)
        }
    }
}


extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
    }
}
