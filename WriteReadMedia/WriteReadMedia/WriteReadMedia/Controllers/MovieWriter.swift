//
//  MovieWriter.swift
//  WriteReadMedia
//
//  Created by 壹九科技1 on 2020/4/21.
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

protocol MovieWriterDelegate {
    func didWriteMovie(at url: URL)
}

let THVideoFilename = "movie.mov";

class MovieWriter {
    
    var delegate: MovieWriterDelegate?
    var isWriting: Bool? = false
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var assetWriterAudioInput: AVAssetWriterInput?
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    private var dispatchQueue: DispatchQueue?
    private weak var ciContext: CIContext?
    private var colorSpace: CGColorSpace?
    
    private var activeFilter: CIFilter?
    
    private var videoSetting: Dictionary<String, Any>?
    private var audioSetting: Dictionary<String, Any>?
    
    private var firstSample: Bool?
    
    init(videoSetting: Dictionary<String, Any>,
         audioSetting: Dictionary<String, Any>,
         dispatchQueue: DispatchQueue) {
        
        self.audioSetting = audioSetting
        self.videoSetting = videoSetting
        self.dispatchQueue = dispatchQueue
        
        ciContext = ContextManager.shared.ciContext
        colorSpace = CGColorSpaceCreateDeviceRGB()
        activeFilter = PhotoFilters.defaultFilter()
        
        firstSample = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterDidChange(_:)), name: THFilterSelectionChangedNotification, object: nil)
        
        
    }
    
    func startWriting() {
        dispatchQueue?.async {[weak self] in
            guard let strongSelf = self else {return}
            let fileType = AVFileType.mov
            strongSelf.assetWriter = try! AVAssetWriter(outputURL: (strongSelf.outputURL()), fileType: fileType)
            
            strongSelf.assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: strongSelf.videoSetting)
            // 设置这个属性表示输入应该对实时性进行针对性优化
            strongSelf.assetWriterVideoInput?.expectsMediaDataInRealTime = true
            let orientation = UIDevice.current.orientation
            strongSelf.assetWriterVideoInput?.transform = TransformForDeviceORientation(orienetation: orientation)
            /// 第一个参数,为了保证最大效率,这里的格式和输入的格式应该保持一致
            let attributes = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
                              kCVPixelBufferWidthKey: strongSelf.videoSetting?[AVVideoWidthKey],
                              kCVPixelBufferHeightKey: strongSelf.videoSetting?[AVVideoHeightKey],
                              kCVPixelFormatOpenGLESCompatibility: kCFBooleanTrue
            ]
            strongSelf.assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: strongSelf.assetWriterVideoInput!, sourcePixelBufferAttributes: attributes as [String : Any])
            if strongSelf.assetWriter?.canAdd(strongSelf.assetWriterVideoInput!) == true {
                strongSelf.assetWriter?.add(strongSelf.assetWriterVideoInput!)
            }
            
            strongSelf.assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: strongSelf.audioSetting)
            strongSelf.assetWriterAudioInput?.expectsMediaDataInRealTime = true
            if strongSelf.assetWriter?.canAdd(strongSelf.assetWriterAudioInput!) == true {
                strongSelf.assetWriter?.add(strongSelf.assetWriterAudioInput!)
            }
            strongSelf.isWriting = true
            strongSelf.firstSample = true
        }
        
    }
    /// 处理音视频两种样本
    func processSampleBuffer(sampleBuffer: CMSampleBuffer) {
        
        if self.isWriting == false {
            return
        }
        // 获取buffer描述, 确定类型
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        
        let mediaType = CMFormatDescriptionGetMediaType(formatDesc)
        if mediaType == kCMMediaType_Video {
        // 获取样本的时间
            let timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            
            if self.firstSample == true {
                
                
                if assetWriter?.startWriting() == true {
                    // 如果是第一个样本, 开启writer session
                    assetWriter?.startSession(atSourceTime: timeStamp)
                } else {
                    print("Failed to start writing")
                }
                firstSample = false
            }
            // 从 buffer适配器池中 创建一个空的 CVPixelBuffer,
            var outputRenderBuffer: CVPixelBuffer?
            guard let pixelBufferPool: CVPixelBufferPool = assetWriterInputPixelBufferAdaptor?.pixelBufferPool else {return}
            let error = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &outputRenderBuffer)
            
            if error != 0 {
                print("Unable to obtain a pixel buffer from the pool.")
                return
            }
            // 获取视频样本的CVPixelBuffer, 创建一个 CIImage
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
            let sourceImage = CIImage(cvPixelBuffer: imageBuffer, options: nil)
            // 使用 filter 筛选器筛选 ciimage
            activeFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
            var filteredImage = activeFilter?.outputImage
            if filteredImage == nil {
                filteredImage = sourceImage
            }
            // 筛选好的image 输出渲染到 前面创建好的空的 CVPixelBuffer中, outputBuffer
            ciContext?.render(filteredImage!,
                              to: outputRenderBuffer!,
                              bounds: filteredImage?.extent ?? .zero,
                              colorSpace: colorSpace)
            // 如果readyForMoreMediadata == true, 则把像素buffer 和 当前样本的时间都附加到BufferAdaptor, 完成对视频样本的处理, 应该释放buffer
            if assetWriterVideoInput?.isReadyForMoreMediaData == true {
                if self.assetWriterInputPixelBufferAdaptor?.append(outputRenderBuffer!, withPresentationTime: timeStamp) == false {
                    print("Error appending pixel buffer.")
                }
            }
            
        } else if self.firstSample == false && mediaType == kCMMediaType_Audio {
            // 如果是音频样本, 则直接添加到input中去就行了
            if self.assetWriterAudioInput?.append(sampleBuffer) == false {
                print("Error appending audio sample buffer.");
            }
        }
    }
    
    func stopWriting() {
        self.isWriting = false
        dispatchQueue?.async {[weak self] in
            guard let strongSelf = self else {return}
            strongSelf.assetWriter?.finishWriting(completionHandler: {
                if strongSelf.assetWriter?.status == AVAssetWriter.Status.completed {
                    DispatchQueue.main.async {
                        let fileUrl = strongSelf.assetWriter?.outputURL
                        strongSelf.delegate?.didWriteMovie(at: fileUrl!)
                    }
                } else {
                    print("Failed to write movie: \(strongSelf.assetWriter?.error)" );

                }
            })
        }
    }
    
    @objc
    func filterDidChange(_ notification: Notification) {
        activeFilter = notification.object as? CIFilter
    }
    

    func outputURL() -> URL {
        let filePath =
            NSTemporaryDirectory().appending("/\(THVideoFilename)")
        let url = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            try! FileManager.default.removeItem(at: url)
        }

        return url;
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
