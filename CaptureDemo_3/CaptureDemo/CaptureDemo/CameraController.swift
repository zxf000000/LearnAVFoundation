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
    var textureCache: CVOpenGLESTextureCache!
    var cameraTexture: CVOpenGLESTexture?
    
    var videoQueue: DispatchQueue!
    
    convenience init(context: CVEAGLContext) {
        self.init()
        self.context = context
   
        let err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &textureCache)
        if err != kCVReturnSuccess {
            print("error creating texture cache, \(err)")
        }
        videoQueue = DispatchQueue(label: "camera.queue")
    }
    // private
    private var activeVideoInput: AVCaptureDeviceInput!
    private var imageOutput: AVCapturePhotoOutput!
    private var photoOutputSetting: AVCapturePhotoSettings!
    private var movieOutput: AVCaptureMovieFileOutput!
    private var outputURL: URL!

    private var deviceTypes: [AVCaptureDevice.DeviceType] = {
        var deviceTypes: [AVCaptureDevice.DeviceType] = [
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
        return AVCaptureSession.Preset.low
    }
    
    func setupSession() throws -> Bool {
        captureSession = AVCaptureSession()
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {return false}
        let videoInput = try AVCaptureDeviceInput(device: videoDevice)
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            activeVideoInput = videoInput
        }
        let _ = setupSessionOutput()
        return true
    }

    func startSession() {
        if captureSession.isRunning == false {
            videoQueue.async {
                self.captureSession.startRunning()
            }


        }
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

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {return}

        let videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)

        err = CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            pixelBuffer,
            nil,
            GLenum(GL_TEXTURE_2D),
            GL_RGBA,                                /// 这个是输出的颜色
            videoDimensions.height,
            videoDimensions.height,
            GLenum(GL_BGRA),                        /// 这个是 pixelbuffer 的格式(也就是输入的颜色), 如果设置的和pixel buffer 即 videoDataOutput的格式不一样,会导致颜色偏差,或者报错
            GLenum(GL_UNSIGNED_BYTE),
            0,
            &cameraTexture)


        if err == kCVReturnSuccess {
            let target = CVOpenGLESTextureGetTarget(cameraTexture!)

            let name = CVOpenGLESTextureGetName(cameraTexture!)

            textureDelegate.textureCreated(with: target, name: name)
        }
        cleanTextures()
        
    }
    
    func cleanTextures() {
        cameraTexture = nil
        CVOpenGLESTextureCacheFlush(textureCache!, 0)
    }
}

