//
//  ViewController.swift
//  CaptureDemo
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var toolsView: UIView!
    
    var button: UIButton = UIButton()
    var previewView: PreviewView!
    
    var cameraControl: CameraController!
    
    var captureButton: UIButton = UIButton()
    var recordButton: UIButton = UIButton()
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        
        setupUI()
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
            cameraControl.startRecording()
        } else {
            cameraControl.stopRecording()
        }
    }


}

extension ViewController: CameraControllerDelegate {
    func deviceConfigurationFailed(with error: Error?) {
        
    }
    func mediaCaptureFailed(with error: Error?) {
        
    }
    func assetLibraryWriteFailed(with error: Error?) {
        
    }
}
