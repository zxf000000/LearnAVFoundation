//
// Created by 壹九科技1 on 2020/4/14.
// Copyright (c) 2020 zxf. All rights reserved.
//

import AVFoundation
import UIKit
import Photos


protocol TextureDelegate {
    func textureCreated(with target: GLenum, name: GLuint)
}

protocol CameraControllerDelegate {
    func deviceConfigurationFailed(with error: Error?)
    func mediaCaptureFailed(with error: Error?)
    func assetLibraryWriteFailed(with error: Error?)
}


class CameraController: NSObject {
    var delegate: CameraControllerDelegate!
    var captureSession: AVCaptureSession!
    
    var textureDelegate: TextureDelegate!
    
    var metaDataOutput: AVCaptureMetadataOutput!
    
    // MARK: Texture
    var videoDataOutput: AVCaptureVideoDataOutput!
    var context: CVEAGLContext!
    var textureCache: CVOpenGLESTextureCache?
    var cameraTexture: CVOpenGLESTexture?
    
    
    convenience init(context: CVEAGLContext) {
        self.init()
        self.context = context
   
        let err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &textureCache)
        
        if err != kCVReturnSuccess {
            print("error creating texture cache, \(err)")
        }
    }
    
    override init() {
        super.init()
    }

    var cameraCount: Int! {
        get {
            return devices().count
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
            if imageOutput != nil {
                if imageOutput.supportedFlashModes.contains(newValue) {
                    photoOutputSetting.flashMode = newValue
                }
            } else {
                delegate.deviceConfigurationFailed(with: nil)
            }
        }
        get {
            return photoOutputSetting.flashMode
        }
    }

    // private
    private var videoQueue: DispatchQueue!
    private var activeVideoInput: AVCaptureDeviceInput!
    private var imageOutput: AVCapturePhotoOutput!
    private var photoOutputSetting: AVCapturePhotoSettings!
    private var movieOutput: AVCaptureMovieFileOutput!
    private var outputURL: URL!

    private var deviceTypes: [AVCaptureDevice.DeviceType] = {
        var deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInDuoCamera,
            .builtInTelephotoCamera,
            .builtInWideAngleCamera
                                    ]
        if #available(iOS 13, *) {
            deviceTypes.append(.builtInUltraWideCamera)
            deviceTypes.append(.builtInDualWideCamera)
            deviceTypes.append(.builtInTripleCamera)
            deviceTypes.append(.builtInUltraWideCamera)
        } else if #available(iOS 11.1, *) {
            deviceTypes.append(.builtInTrueDepthCamera)
        }
        return deviceTypes
    }()
    
    func devices() -> [AVCaptureDevice] {
        let deviceDiscoverSession = AVCaptureDevice
            .DiscoverySession(deviceTypes: deviceTypes
                , mediaType: .video, position: .front)
        return deviceDiscoverSession.devices
    }

    func sessionPreset() -> AVCaptureSession.Preset {
        return AVCaptureSession.Preset.hd1280x720
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

        let _ = setupSessionOutput()


        videoQueue = DispatchQueue(label: "com.videoCaptureDemo.videoQueue")
        return true
    }

    func startSession() {
        if captureSession.isRunning == false {
            videoQueue.async {[weak self] in
                guard let self = self else {return}
                self.captureSession.startRunning()
                glCheckError()

            }
        }
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
        case .faceUp:
            orientation = .portrait
        case .faceDown:
            orientation = .portrait
        @unknown default:
            orientation = .landscapeRight
        }
        return orientation!
    }


    private func camera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = self.devices()
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


// MARK: Texture
extension CameraController {
    func setupSessionOutput() -> Bool {
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as [String: Any]
        /// 这个队列可以指定专门的队列,
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        } else {
            return false
        }
        return true
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var err: CVReturn? = nil
        glCheckError()

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        glCheckError()

        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {return}
        glCheckError()

        let videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        glCheckError()

        err = CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache!,
            pixelBuffer,
            nil,
            GLenum(GL_TEXTURE_2D),
            GL_RGBA,
            videoDimensions.height,
            videoDimensions.height,
            GLenum(GL_RGBA),
            GLenum(GL_UNSIGNED_BYTE),
            0,
            &cameraTexture)

        
        if err == kCVReturnSuccess {
            let target = CVOpenGLESTextureGetTarget(cameraTexture!)

            let name = CVOpenGLESTextureGetName(cameraTexture!)

            textureDelegate.textureCreated(with: target, name: name)
        }
    }
    
    func cleanTextures() {
//        cameraTexture.deallocate()
        CVOpenGLESTextureCacheFlush(textureCache!, 0)
    }
}

