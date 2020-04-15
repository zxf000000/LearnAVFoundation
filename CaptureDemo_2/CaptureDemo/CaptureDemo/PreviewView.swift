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

    var overlayLayer: CALayer!
    var faceLayers: [Int: CALayer]!


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    func setupView() {
        faceLayers = [Int: CALayer]()
        let previewLayer = layer as! AVCaptureVideoPreviewLayer
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        overlayLayer = CALayer()
        overlayLayer.frame = bounds
        overlayLayer.sublayerTransform = makePerspectiveTransform(1000)
        previewLayer.addSublayer(overlayLayer)
    }

    func makePerspectiveTransform(_ eyePosition: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / eyePosition
        return transform
    }


}

extension PreviewView: FaceDetectionDelegate {
    func didDetectionFaces(_ faces: [AVMetadataObject]) {
        let transformedFaces = self.transformedFaces(from: faces)
        let lostFaces = faceLayers.keys
        for face in transformedFaces {
            if let aFace = face as? AVMetadataFaceObject {
                let faceID = aFace.faceID
                let _ = lostFaces.dropFirst(faceID)

//                if let index = lostFaces.firstIndex(of: faceID) {
//                }
                var layer = faceLayers[faceID]
                if layer == nil {
                    layer = makeFaceLayer()
                    overlayLayer.addSublayer(layer!)
                    faceLayers[faceID] = layer
                }
                layer?.transform = CATransform3DIdentity
                layer?.frame = face.bounds
                
                if aFace.hasRollAngle {
                    let transform = transformForRollAngle(aFace.rollAngle)
                    layer?.transform = CATransform3DConcat(layer?.transform ?? CATransform3DIdentity, transform)
                }
                if aFace.hasYawAngle {
                    let transform = transformForYawAngle(aFace.yawAngle)
                    layer?.transform = CATransform3DConcat(layer?.transform ?? CATransform3DIdentity, transform)
                }
                
            }
            
            for faceId in lostFaces {
                let layer = faceLayers[faceId]
                layer?.removeFromSuperlayer()
                faceLayers.removeValue(forKey: faceId)
            }
        }
    }
    
    func transformForRollAngle(_ rollAngle: CGFloat) -> CATransform3D {
        let rollAngleInRadians = degreesToRadians(rollAngle)
        return CATransform3DMakeRotation(rollAngleInRadians, 0, 0, 1)
    }
    
    func transformForYawAngle(_ yawAngle: CGFloat) -> CATransform3D {
        let yawAngleInRadians = degreesToRadians(yawAngle)
        let yawTransform = CATransform3DMakeRotation(yawAngleInRadians, 0, -1, 0)
        return CATransform3DConcat(yawTransform, oreintationTransform())
    }
    
    func oreintationTransform() -> CATransform3D {
        var angle: CGFloat = 0
        switch UIDevice.current.orientation {
        
        case .unknown:
            break
        case .portrait:
            angle = 0.0
        case .portraitUpsideDown:
            angle = CGFloat(Double.pi)
        case .landscapeLeft:
            angle = CGFloat(Double.pi) / CGFloat(2)
        case .landscapeRight:
            angle = CGFloat(-Double.pi) / CGFloat(2)
        default:
            break
        }
        return CATransform3DMakeRotation(angle, 0, 0, 1)
    }
    
    func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(Double.pi) / CGFloat(180)
    }
    
    func makeFaceLayer() -> CALayer {
        let layer = CALayer()
        layer.borderWidth = 5
        layer.borderColor = UIColor(red: 0.188, green: 0.517, blue: 0.877, alpha: 1).cgColor
        return layer
    }

    func transformedFaces(from faces: [AVMetadataObject]) -> [AVMetadataObject] {
        var transformedFaces = [AVMetadataObject]()
        for face in faces {
            if let transformedFace = (layer as! AVCaptureVideoPreviewLayer).transformedMetadataObject(for: face) {
                transformedFaces.append(transformedFace)
            }
        }
        return transformedFaces
    }
}


