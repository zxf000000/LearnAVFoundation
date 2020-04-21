//
//  BaseCameraController.swift
//  WriteReadMedia
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

protocol CameraControllerDelegate {
    func deviceConfigurationFailedWithError(error: String)
    func mediaCaptureFailedWithError(error: String)
    func assetLibraryWriteFailedWithError(error: String)
}

class BaseCameraController: NSObject {
    var delegate: CameraControllerDelegate?
    var captureSession: AVCaptureSession?
    var dispatchQueue: DispatchQueue?
    private var activeVideoInput: AVCaptureDeviceInput?
    
    private var cameraCount: Int {
        return (devices(position: .front).count + devices(position: .back).count)
    }
    private var outputURL: URL?

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
    
    override init() {
        super.init()
        dispatchQueue = DispatchQueue(label: "com.tapharmonic.CaptureDispatchQueue")
    }
    
    func setupSession() -> String {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = sessionPreset()
        if setupSessionInput() == false {
            return "111"
        }
        if setupSessionOutput() == false {
            return "222"
        }

        return ""
    }
    
    func setupSessionInput() -> Bool {
        let videoDevice = AVCaptureDevice.default(for: .video)
        let videoInput = try! AVCaptureDeviceInput(device: videoDevice!)
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            return false
        }
        
        let audioDevice = AVCaptureDevice.default(for: .audio)
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        if captureSession?.canAddInput(audioInput) == true {
            captureSession?.addInput(audioInput)
        } else {
            return false
        }
        return true
    }
    
    func setupSessionOutput() -> Bool {
        return false
    }
    
    func startSession() {
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }
    
    func stopSession() {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
    
    func devices(position: AVCaptureDevice.Position) -> [AVCaptureDevice] {
        let deviceDiscoverSession = AVCaptureDevice
            .DiscoverySession(deviceTypes: deviceTypes
                , mediaType: .video, position: .front)
        return deviceDiscoverSession.devices
    }
    
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let aDevices = devices(position: position)
        for device in aDevices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    
    func switchCameras() -> Bool {

        if canSwitchCameras() == false {
            return false
        }

        let videoDevice = inactiveCamera()
        let videoInput = try! AVCaptureDeviceInput(device: videoDevice)
        captureSession?.beginConfiguration()
        captureSession?.removeInput(activeVideoInput!)
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
            activeVideoInput = videoInput
        } else {
            captureSession?.addInput(activeVideoInput!)
        }
        captureSession?.commitConfiguration()
        
        return true
    }
    func canSwitchCameras() -> Bool {
        return cameraCount > 1
    }


    
    private func inactiveCamera() -> AVCaptureDevice {
        var device: AVCaptureDevice? = nil
        if cameraCount > 1 {
            if activeCamera().position == .back {
                device = cameraWithPosition(.front)
            } else {
                device = cameraWithPosition(.back)
            }
        }
        return device!
    }
    
    func sessionPreset() -> AVCaptureSession.Preset {
        return AVCaptureSession.Preset.high
    }
    
    func activeCamera() -> AVCaptureDevice {
        return activeVideoInput!.device
    }


}

