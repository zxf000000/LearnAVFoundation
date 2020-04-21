//
//  ViewController.swift
//  StopNGo_Swift
//
//  Created by 壹九科技1 on 2020/4/21.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var started: Bool?
    var frameDuration: CMTime?
    var nextPTS: CMTime?
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    var photoOutput: AVCapturePhotoOutput?
    var outputURL: URL?
    
    @IBOutlet weak var takePickerItem: UIBarButtonItem!
    @IBOutlet weak var startItem: UIBarButtonItem!
    @IBOutlet weak var previewView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    func setupAVCapture() -> Bool {
        frameDuration = CMTimeMakeWithSeconds(1.0/5.0, preferredTimescale: 90000)
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {return false}
        
        let input = try! AVCaptureDeviceInput(device: backCamera)
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput!) {
            session.addOutput(photoOutput!)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.frame = previewView.bounds
        
        let rootLayer = previewView.layer
        rootLayer.backgroundColor = UIColor.black.cgColor
        rootLayer.addSublayer(previewLayer)
        
        session.startRunning()
        
        return true
    }
    
    static func DegreesToRadians(degree: CGFloat) -> CGFloat {return degree * (CGFloat(Double.pi / 180))}
    
    func setupAssetWriterForURL(fileURL: URL, formatDescription: CMFormatDescription) {
        assetWriter = try! AVAssetWriter(outputURL: fileURL, fileType: .mov)
        
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
        assetWriterInput?.expectsMediaDataInRealTime = true
        if assetWriter?.canAdd(assetWriterInput!) == true {
            assetWriter?.add(assetWriterInput!)
        }
        
        var rotationDegress: CGFloat = 0
        switch UIDevice.current.orientation {
        case .portrait:
            break
        case .portraitUpsideDown:
            rotationDegress = -90
        case .landscapeLeft:
            rotationDegress = 0
        case .landscapeRight:
            rotationDegress = 180
        case .faceUp:
            break
        case .faceDown:
            break
        default:
            break
        }
        let rotationRadians = ViewController.DegreesToRadians(degree: rotationDegress)
        assetWriterInput?.transform  = CGAffineTransform(rotationAngle: rotationRadians)
        nextPTS = .zero
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: nextPTS!)
    }

    @IBAction func startStop(_ sender: Any) {
        
    }
    @IBAction func takePicker(_ sender: Any) {
        
//        let connection = photoOutput?.connection(with: .video)
        photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if assetWriter == nil {
            let path = NSTemporaryDirectory().appending("/\(mach_absolute_time()).mov")
            outputURL = URL(fileURLWithPath: path)
            CMSampleBufferGetFormatDescription(photo.pixelBuffer)
            let formatDescription = photo.pixelBuffer
            
        }
        
    }
}
