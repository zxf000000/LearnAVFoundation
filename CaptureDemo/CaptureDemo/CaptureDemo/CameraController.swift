//
// Created by 壹九科技1 on 2020/4/14.
// Copyright (c) 2020 zxf. All rights reserved.
//

import AVFoundation
import UIKit
import Photos


protocol CameraControllerDelegate {
    func deviceConfigurationFailed(with error: Error?)
    func mediaCaptureFailed(with error: Error?)
    func assetLibraryWriteFailed(with error: Error?)
}

protocol CameraZoomingDelegate {
    func rampedZoomToValue(_ value: CGFloat)
}

protocol FaceDetectionDelegate {
    func didDetectionFaces(_ faces: [AVMetadataObject])
}

protocol CodeDetectionDelegate {
    func didDetectCodes(_ codes: [AVMetadataObject])
}

class CameraController: NSObject {
    var delegate: CameraControllerDelegate!
    var captureSession: AVCaptureSession!
    var zoomingDelegate: CameraZoomingDelegate!
    var faceDetectionDelegate: FaceDetectionDelegate!
    var codeDetectionDelegate: CodeDetectionDelegate!
    var metaDataOutput: AVCaptureMetadataOutput!
    
    var cameraCount: Int! {
        get {
//            let deviceDiscoverSession = AVCaptureDevice
//                    .DiscoverySession(deviceTypes: [.builtInDualCamera,
//            .builtInDualWideCamera,
//            .builtInDuoCamera,
//            .builtInTelephotoCamera,
//            .builtInTripleCamera,
//            .builtInTrueDepthCamera,
//            .builtInUltraWideCamera,
//            .builtInWideAngleCamera]
//                    , mediaType: .video, position: .front)
//            deviceDiscoverSession.devices.count
            return AVCaptureDevice.devices(for: .video).count
        }
    }
    var cameraHasTorch: Bool! {
        return self.activeCamera().hasTorch
    }
    var cameraHasFlash: Bool! {
        get {
            return self.activeCamera().hasFlash
        }
    }
    var cameraSupportsTapToFocus: Bool!
    var cameraSupportsTapToExpose: Bool!

    var torchMode: AVCaptureDevice.TorchMode! {
        set {
            let device = self.activeCamera()
            if device.isTorchModeSupported(newValue) {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = newValue
                    device.unlockForConfiguration()
                } catch {
                    self.delegate.deviceConfigurationFailed(with: nil)
                }
            }
        }
        get {
            return self.activeCamera().torchMode
        }
    }
    var flashMode: AVCaptureDevice.FlashMode! {
        set {
            let device = self.activeCamera()
            if device.isFlashModeSupported(newValue) {
                do {
                    try device.lockForConfiguration()
                    device.flashMode = newValue
                    device.unlockForConfiguration()
                } catch {
                    self.delegate.deviceConfigurationFailed(with: nil)
                }
            }
        }
        get {
            return activeCamera().flashMode
        }
    }

    // private
    private var videoQueue: DispatchQueue!
    private var activeVideoInput: AVCaptureDeviceInput!
    private var imageOutput: AVCapturePhotoOutput!
    private var movieOutput: AVCaptureMovieFileOutput!
    private var outputURL: URL!


    func sessionPreset() -> AVCaptureSession.Preset {
        return AVCaptureSession.Preset.vga640x480
    }
    
    func setupSessionInputs() {
        
    }
    
    func setupSession() throws -> Bool {
        captureSession = AVCaptureSession()
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {return false}
        let videoInput = try AVCaptureDeviceInput(device: videoDevice)
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            activeVideoInput = videoInput
        }
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {return false}
        let audioInput = try AVCaptureDeviceInput(device: audioDevice)
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        // setting 放到后面捕捉的时候配置
        imageOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(imageOutput) {
            captureSession.addOutput(imageOutput)
        }
        movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        videoQueue = DispatchQueue(label: "com.videoCaptureDemo.videoQueue")
        return true
    }

    func startSession() {
        if captureSession.isRunning == false {
            videoQueue.async {[weak self] in
                guard let self = self else {return}
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            videoQueue.async { [weak self] in
                guard let self = self else {return}
                self.captureSession.stopRunning()
            }
        }
    }

    func switchCameras() throws -> Bool {

        if canSwitchCameras() == false {
            return false
        }

        let videoDevice = inactiveCamera()
        let videoInput = try AVCaptureDeviceInput(device: videoDevice)
        if videoInput != nil {
            captureSession.beginConfiguration()
            captureSession.removeInput(activeVideoInput)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                activeVideoInput = videoInput
            } else {
                captureSession.addInput(activeVideoInput)
            }
            captureSession.commitConfiguration()
        } else {
            delegate.deviceConfigurationFailed(with: nil)
            return false
        }
        return true
    }
    func canSwitchCameras() -> Bool {
        return cameraCount > 1
    }

    /// 对焦
    func focus(at point: CGPoint) throws {
        let device = activeCamera()
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
            do {
                // 锁住设置项, 只允许当前程序修改
                try device.lockForConfiguration()
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
                device.unlockForConfiguration()
            } catch {
                delegate.deviceConfigurationFailed(with: nil)
            }
        }
    }

    func expose(at point: CGPoint) {
        let device = activeCamera()
        let exposureMode = AVCaptureDevice.ExposureMode.autoExpose
        // 判断设备是否支持自动曝光
        if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
            do {
                // 如果支持,使用KVO来确定设备的 adjustingExposure 状态, 观察属性是否可以知道曝光调整什么时候完成
                // 我们有机会在该点上锁定曝光
                try device.lockForConfiguration()

                device.exposurePointOfInterest = point
                device.exposureMode = exposureMode
                if device.isExposureModeSupported(.locked) {
                    device.addObserver(self,
                                       forKeyPath: "adjustingExposure",
                                       options: .new,
                                       context: nil)
                }
                device.unlockForConfiguration()
            } catch {
                delegate.deviceConfigurationFailed(with: nil)
            }
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "adjustingExposure" {
            guard let device = object as? AVCaptureDevice else {return}
            // 确定设备不再调整曝光等级
            if device.isAdjustingExposure && device.isExposureModeSupported(.locked) {
                device.removeObserver(self, forKeyPath: "adjustingExposure")
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else  {return}
                    do {
                        try device.lockForConfiguration()
                        // 确定是否可以设置为 locked
                        device.exposureMode = .locked
                        device.unlockForConfiguration()
                    } catch {
                        strongSelf.delegate.deviceConfigurationFailed(with: nil)
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // 重设对焦和曝光
    func resetFocusAndExposureModes() {
        let device = activeCamera()
        let focusMode = AVCaptureDevice.FocusMode.autoFocus
        let canResetFocus = device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode)
        let exposureMode = AVCaptureDevice.ExposureMode.autoExpose
        let canResetExpose = device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode)
        let centerPoint = CGPoint(x: 0.5, y: 0.5)
        do {
            try device.lockForConfiguration()
            if canResetFocus {
                device.focusMode = focusMode
                device.focusPointOfInterest = centerPoint
            }
            if canResetExpose {
                device.exposureMode = exposureMode
                device.exposurePointOfInterest = centerPoint
            }
            device.unlockForConfiguration()
        } catch {
            delegate.deviceConfigurationFailed(with: nil)
        }
    }

    /// media capture methods
    func captureStillImage() {
        let connection = self.imageOutput.connection(with: .video)
        if connection?.isVideoOrientationSupported == true {
            connection?.videoOrientation = currentVideoOrientation()
        }

        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        self.imageOutput.capturePhoto(with: settings, delegate: self)
    }
    func startRecording() {
        if self.isRecording() == false {
            let connection = movieOutput.connection(with: .video)
            if connection?.isVideoOrientationSupported == true {
                connection?.videoOrientation = currentVideoOrientation()
            }
            if connection?.isVideoStabilizationSupported == true {
                connection?.preferredVideoStabilizationMode = .auto
            }
            let device = activeCamera()
            if device.isSmoothAutoFocusSupported == true {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = true
                    device.unlockForConfiguration()
                } catch {
                    delegate.deviceConfigurationFailed(with: nil)
                }
                
                outputURL = uniqURL()
                movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            }
        }
    }
    func stopRecording()  {
        if self.isRecording() == true {
            self.movieOutput.stopRecording()
        }
    }
    func isRecording() -> Bool {
        return self.movieOutput.isRecording
    }

    func uniqURL() -> URL? {
        let temPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let filePath = temPath?.appending("/kamerra_movie.mov") ?? ""
            
        return URL(fileURLWithPath: filePath)
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation?
        switch UIDevice.current.orientation {
        case .unknown:
            orientation = .landscapeRight
        case .portrait:
            orientation = .portrait
        case .portraitUpsideDown:
            orientation = .portraitUpsideDown
        case .landscapeLeft:
            orientation = .landscapeLeft
        case .landscapeRight:
            orientation = .landscapeRight
        @unknown default:
            orientation = .landscapeRight
        }
        return orientation!
    }

    // 是否支持曝光
    func cameraCanSupportTapFoExpose() -> Bool {
        return activeCamera().isExposurePointOfInterestSupported
    }

    // 是否支持兴趣点
    func cameraCanSupportTapToFocus() -> Bool {
        return activeCamera().isFocusPointOfInterestSupported
    }

    private func camera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: .video)
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }

    private func activeCamera() -> AVCaptureDevice {
        return activeVideoInput.device
    }

    private func inactiveCamera() -> AVCaptureDevice {
        var device: AVCaptureDevice? = nil
        if cameraCount > 1 {
            if activeCamera().position == .back {
                device = camera(with: .front)
            } else {
                device = camera(with: .back)
            }
        }
        return device!
    }

}

extension CameraController {
    func cameraSupportHighFrameRateCapture() -> Bool {
        return activeCamera().supportsHighFrameRateCapture()
    }
    
    func enableHighFrameRateCapture() -> Bool {
        return activeCamera().enabledHightFrameRateCapture()
    }
}

// MARK: detectionFace
extension CameraController {
    func setupSessionOutput() -> Bool {
        metaDataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            let metaDataObjectTypes: [AVMetadataObject.ObjectType] = [AVMetadataObject.ObjectType.face]
            metaDataOutput.metadataObjectTypes = metaDataObjectTypes
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            return true
        } else {
            return false
        }
    }
}

extension CameraController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        faceDetectionDelegate.didDetectionFaces(metadataObjects)
        
//        for obj in metadataObjects {
//            if let object = obj as? AVMetadataFaceObject {
//
//
//
//            }
//        }
        
    }

}

// MARK: zoom
extension CameraController {
    func cameraSupportsZoom() -> Bool {
       return activeCamera().activeFormat.videoMaxZoomFactor > 1.0
    }
    func setZoomValue(_ value: CGFloat) {
        if activeCamera().isRampingVideoZoom == false {
            do {
                try activeCamera().lockForConfiguration()
                // 要提供线性增长的感觉,所以是哦那个pow函数
                let zoomValue = pow(maxZoomFactor(), value)
                activeCamera().videoZoomFactor = zoomValue
                activeCamera().unlockForConfiguration()
            } catch {
                delegate.deviceConfigurationFailed(with: nil)
            }
        }
    }
    func rampZoomToValue(_ value: CGFloat) {
        setZoomValue(value)
    }
    func cancelZoom() {
        do {
            try activeCamera().lockForConfiguration()
            // 要提供线性增长的感觉,所以是哦那个pow函数
            activeCamera().cancelVideoZoomRamp()
            activeCamera().unlockForConfiguration()
        } catch {
            delegate.deviceConfigurationFailed(with: nil)
        }

    }
    func maxZoomFactor() -> CGFloat {
        return min(activeCamera().activeFormat.videoMaxZoomFactor, 4.0)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                            previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                            resolvedSettings: AVCaptureResolvedPhotoSettings,
                            bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let sampleBuffer = photoSampleBuffer {
            if let imageData: Data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
                    forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: sampleBuffer) {
                if let image = UIImage(data: imageData) {
                    PHPhotoLibrary.shared()
                            .performChanges({
                                                PHAssetChangeRequest.creationRequestForAsset(from: image)
                                            }, completionHandler: { result, error in
                                print("保存完成")
                            })
                }
            } else {
                print("null sample buffer \(error?.localizedDescription)")
            }
            
        }
    }
}

extension CameraController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            delegate.mediaCaptureFailed(with: error)
        } else {
            print(outputURL!)
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                
            }) { (result, error) in
                
            }
        }
    }
    
    
}
