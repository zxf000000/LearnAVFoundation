//
// Created by 壹九科技1 on 2020/4/14.
// Copyright (c) 2020 zxf. All rights reserved.
//

import UIKit
import AVFoundation

protocol PreviewViewDelegate: NSObject {
    func tappedToFocus(at point: CGPoint)
    func tappedToExpose(at point: CGPoint)
    func tappedToResetFocusAndExposure()
}

class PreviewView: UIView {
    var session: AVCaptureSession! {
        set {
            if let preLayer = (layer as? AVCaptureVideoPreviewLayer) {
                preLayer.session = newValue
            }
        }
        get {
            if let preLayer = (layer as? AVCaptureVideoPreviewLayer) {
                return preLayer.session
            }
            return nil
        }
    }
    weak var delegate: PreviewViewDelegate!
    var tapToFocusEnabled: Bool!
    var tapToExposeEnabled: Bool!
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    /*
    *  将屏幕坐标系的点转换到摄像投坐标系的点
    */
    func captureDevicePoint(for point: CGPoint) -> CGPoint {
        if let layer = (self.layer as? AVCaptureVideoPreviewLayer) {
            return layer.captureDevicePointConverted(fromLayerPoint: point)
        }
        return .zero
    }



}
