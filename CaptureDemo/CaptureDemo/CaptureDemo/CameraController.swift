//
// Created by 壹九科技1 on 2020/4/14.
// Copyright (c) 2020 zxf. All rights reserved.
//

import AVFoundation

protocol CameraControllerDelegate {
    func deviceConfigurationFailed(with error: Error)
    func mediaCaptureFailed(with error: Error)
    func assetLibraryWriteFailed(with error: Error)
}

class CameraController: NSObject {
    var delegate: CameraControllerDelegate!
    var captureSession: AVCaptureSession!

    var cameraCount: Int!
    var cameraHasTorch: Bool!
    var cameraHasFlash: Bool!
    var cameraSupportsTapToFocus: Bool!
    var cameraSupportsTapToExpose: Bool!

    var torchMode: AVCaptureDevice.TorchMode!
    var flashMode: AVCaptureDevice.FlashMode!

    // private
    private var videoQueue: DispatchQueue!
    private var activeVideoInput: AVCaptureDeviceInput!
    private var imageOutput: AVCapturePhotoOutput!
    private var movieOutput: AVCaptureMovieFileOutput!
    private var outputURL: URL!


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

    }

    func stopSession() {

    }

    func switchCameras() -> Bool {
        return false
    }
    func canSwitchCameras() -> Bool {
        return false
    }


    func focus(at point: CGPoint) {

    }

    func expose(at point: CGPoint) {
    }

    func resetFocusAndExposureModes() {
    }

    /// media capture methods
    func captureStillImage() {

    }
    func startRecording() {

    }
    func stopRecording() {

    }
    func isRecording() -> Bool {
        return false
    }
}
