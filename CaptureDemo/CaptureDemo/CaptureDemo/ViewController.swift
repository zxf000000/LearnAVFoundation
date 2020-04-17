//
//  ViewController.swift
//  CaptureDemo
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var switcher: UISwitch! = UISwitch()
    
    var toolsView: UIView!
    var slider: UISlider!
    var button: UIButton = UIButton()
    var previewView: PreviewView!
    
    var cameraControl: CameraController!
    
    var captureButton: UIButton = UIButton()
    var recordButton: UIButton = UIButton()
    var detectFaceButton: UIButton = UIButton()

    override func viewDidLoad() {
    super.viewDidLoad()
        
        setupUI()
        
        tapStartButton()
    }

    func setupUI() {
        
        previewView = PreviewView()
        previewView.frame = view.bounds
        view.addSubview(previewView)
        
        toolsView = UIView()
        toolsView.frame = view.bounds
        toolsView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        view.addSubview(toolsView)
        
        button.center = view.center
        button.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle("start", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(tapStartButton), for: .touchUpInside)
        toolsView.addSubview(button)
        
        captureButton.center = CGPoint(x: view.center.x, y: view.center.y + 100)
        captureButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        captureButton.setTitle("captureImage", for: .normal)
        captureButton.backgroundColor = .red
        captureButton.addTarget(self, action: #selector(tapCaptureButton), for: .touchUpInside)
        toolsView.addSubview(captureButton)
        
        recordButton.center = CGPoint(x: view.center.x, y: view.center.y + 150)
        recordButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        recordButton.setTitle("record", for: .normal)
        recordButton.backgroundColor = .red
        recordButton.addTarget(self, action: #selector(tapRecordButton), for: .touchUpInside)
        toolsView.addSubview(recordButton)

        switcher.frame = CGRect(x: 20, y: 130, width: 100, height: 40)
        toolsView.addSubview(switcher)
        switcher.addTarget(self, action: #selector(switcherChange), for: .valueChanged)
        
        detectFaceButton.center = CGPoint(x: view.center.x, y: view.center.y + 200)
        detectFaceButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        detectFaceButton.setTitle("detectFace", for: .normal)
        detectFaceButton.backgroundColor = .red
        detectFaceButton.addTarget(self, action: #selector(tapdetectFaceButton), for: .touchUpInside)
        toolsView.addSubview(detectFaceButton)
        
        slider = UISlider(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 30))
        view.addSubview(slider)
        slider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        
    }
    
    
        
    @objc
    func switcherChange() {
        do {
            let _ = try cameraControl.switchCameras()
        } catch {
            
        }
        
    }
    
    @objc
    func tapdetectFaceButton() {
        cameraControl.faceDetectionDelegate = previewView
        let _ = cameraControl.setupSessionOutput()
    }
    
    @objc
    func sliderValueChange() {
        cameraControl.rampZoomToValue(CGFloat(slider.value))
    }

    @objc
    func tapStartButton() {
        cameraControl = CameraController()
        cameraControl.delegate = self
        do {
            let _ = try cameraControl.setupSession()
            previewView.session = cameraControl.captureSession
            cameraControl.startSession()

        } catch {

        }


    }
    
    @objc
    func tapCaptureButton() {
        cameraControl.captureStillImage()
    }
    
    @objc
    func tapRecordButton() {
        recordButton.isSelected = !recordButton.isSelected
        if recordButton.isSelected {
            let _ = cameraControl.enableHighFrameRateCapture()
            cameraControl.startRecording()
            
            
        } else {
            cameraControl.stopRecording()
        }
    }


}

extension ViewController: CameraControllerDelegate {
    func deviceConfigurationFailed(with error: Error?) {
        print("deviceConfigurationFailed")
        
    }
    func mediaCaptureFailed(with error: Error?) {
        print("mediaCaptureFailed")
    }
    func assetLibraryWriteFailed(with error: Error?) {
        print("assetLibraryWriteFailed")        
    }
}
