//
//  CompositionExporter.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation
import UIKit
import Photos

class CompositionExporter: NSObject {
    var exporting: Bool = false
    var progress: CGFloat = 0
    
    private var composition: Composition!
    private var exportSession: AVAssetExportSession!
    
    private var timer: Timer?
    
    init(compositon: Composition) {
        self.composition = compositon
        
    }
    
    func monitorExportProgress() {
        let delayInSeconds = 0.1
        let delta = UInt64(delayInSeconds) * NSEC_PER_SEC
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(delta), repeats: true, block: { [weak self](timer) in
            guard let strongSelf = self else {return}
            let status = strongSelf.exportSession.status
            
            print(CGFloat(strongSelf.exportSession.progress))
            if status == .exporting {
                strongSelf.progress = CGFloat(strongSelf.exportSession.progress)
            } else {
                strongSelf.exporting = false
                strongSelf.timer?.invalidate()
                strongSelf.timer = nil
            }
        })
    }
    
    func writeExportedVideoToPhotoLibrary() {
        guard let exportURL  = exportSession.outputURL else {
            return
            
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL)
        }) { (result, error) in
            if result {
                print("save to album success!")
            } else {
                print("save to album error!")
            }
            print(self.exportSession.outputURL?.absoluteString ?? "")

        }
        
    }
    
    func exportURL() -> URL {
        var filePath = ""
        var count = 0
        repeat {
            filePath = NSTemporaryDirectory()
            let fileNameString = "Masterpiece-\(Int(Date().timeIntervalSince1970)).m4v"
            filePath = filePath.appending("/\(fileNameString)")
            count += 1
        } while FileManager.default.fileExists(atPath: filePath)
        
        return URL(fileURLWithPath: filePath)

    }
    
    func beginExport() {
        exportSession = composition.makeExportable()
        exportSession.outputURL = exportURL()
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            // To be implemented
            let status = self.exportSession.status
            print("complete")
            if status == .completed {
                self.writeExportedVideoToPhotoLibrary()
            } else {
                print("export failed")
            }
            
        }
        exporting = true
        monitorExportProgress()
    }
    
    
}
