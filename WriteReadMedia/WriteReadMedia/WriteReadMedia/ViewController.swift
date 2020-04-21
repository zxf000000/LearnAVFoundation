//
//  ViewController.swift
//  WriteReadMedia
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var controller: CameraController!
    var previewView: PreviewView!
    
    var filterSelectorView: FilterSelectorView!
    
    @IBOutlet weak var overlayView: OverlayView!
    
    var captureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        controller = CameraController()
        let frame = view.bounds
        let context = ContextManager.shared.eaglContext
        
        previewView = PreviewView(frame: frame, context: context!)
        previewView.filter = PhotoFilters.defaultFilter()
        
        controller.imageTarget = previewView
        
        previewView.coreImageContext = ContextManager.shared.ciContext
        
        view.insertSubview(previewView, belowSubview: overlayView)
        
        if controller.setupSession().count == 0 {
            controller.startSession()
        }
    }
    
    @objc func captureOrRecord(_ sender: UIButton) {
        if controller.isRecording == false {
            DispatchQueue.init(label: "com.tapharmonic.kamera").async {
                self.controller.startRecording()
            }
        } else {
            self.controller.stopRecording()
        }
        sender.isSelected = !sender.isSelected
    }
    
    func setupUI() {
        filterSelectorView = FilterSelectorView(frame: CGRect(x: 0, y: 44, width: view.bounds.size.width, height: 48))
        view.addSubview(filterSelectorView)
        
        captureButton = CaptureButton(mode: .Video)
        overlayView.addSubview(captureButton)
        
        captureButton.addTarget(self, action: #selector(captureOrRecord(_:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = CGRect(x: (overlayView.bounds.width - 68) / 2, y: overlayView.bounds.height - 68, width: 68, height: 68)

    }
    
    
}



