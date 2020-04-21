//
//  CameraController.swift
//  WriteReadMedia
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation
import CoreImage
import Photos

protocol ImageTarget {
    func setImage(image: CIImage)
}


class CameraController: BaseCameraController {
    
    var isRecording: Bool = false
    var imageTarget: ImageTarget?
    
    var videoDataOutput: AVCaptureVideoDataOutput?
    var audioDataOutput: AVCaptureAudioDataOutput?
    
    var movieWriter: MovieWriter!
    override init() {
        super.init()
        
        
    }
    
    override func setupSessionOutput() -> Bool {
        videoDataOutput = AVCaptureVideoDataOutput()
        let options = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as? [String: Any]
        videoDataOutput?.videoSettings = options
        videoDataOutput?.alwaysDiscardsLateVideoFrames = false          // 设置为 false 可以让我们捕捉到全部可用帧
        videoDataOutput?.setSampleBufferDelegate(self, queue: dispatchQueue)
        if captureSession?.canAddOutput(videoDataOutput!) == true {
            captureSession?.addOutput(videoDataOutput!)
        } else {
            return false
        }
        
        audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput?.setSampleBufferDelegate(self, queue: dispatchQueue)
        
        if captureSession?.canAddOutput(audioDataOutput!) == true {
            captureSession?.addOutput(audioDataOutput!)
        } else {
            return false
        }
        
        let fileType = AVFileType.mov
        guard let videoSetting = videoDataOutput?.recommendedVideoSettingsForAssetWriter(writingTo: fileType), let audioSetting = audioDataOutput?.recommendedAudioSettingsForAssetWriter(writingTo: fileType) else {return false}
        
        movieWriter = MovieWriter(videoSetting: videoSetting, audioSetting: audioSetting as! [String: Any], dispatchQueue: dispatchQueue ?? DispatchQueue.main)
        
        movieWriter.delegate = self
        
        return true
    }
    
    override func sessionPreset() -> AVCaptureSession.Preset {
        return .medium
    }
    
    func startRecording() {
        movieWriter.startWriting()
        isRecording = true
    }
    
    func stopRecording() {
        movieWriter.stopWriting()
        isRecording = false
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        movieWriter.processSampleBuffer(sampleBuffer: sampleBuffer)
        
        if output == videoDataOutput {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let sourceImage = CIImage(cvImageBuffer: imageBuffer)
            imageTarget?.setImage(image: sourceImage)
        } else {
            
        }
    }
    
}

extension CameraController: MovieWriterDelegate {
    func didWriteMovie(at url: URL) {
        // 保存到相册
        PHPhotoLibrary.shared().performChanges({
             PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)

        }) { (result, error) in
            print("save movie \(error?.localizedDescription)")
        }
    }
}
