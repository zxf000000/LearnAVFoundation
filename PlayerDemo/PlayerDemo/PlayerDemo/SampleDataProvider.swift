//
//  SampleDataProvider.swift
//  PlayerDemo
//
//  Created by 壹九科技1 on 2020/4/10.
//  Copyright © 2020 YJKJ. All rights reserved.
//

import UIKit
import AVFoundation

typealias SampleDataCompletionBlock = ((Data) -> Void)

class SampleDataProvider {
    
    class func loadAudioSamples(from asset: AVAsset, completitonBlock: @escaping SampleDataCompletionBlock) {
        let tracks = "tracks"
        asset.loadValuesAsynchronously(forKeys: [tracks]) {
            let status = asset.statusOfValue(forKey: tracks, error: nil)
            var sampleData: Data? = nil
            if status == .loaded {
                sampleData = self.readAudioSample(from: asset)
            }
            guard let data = sampleData else {return}
            DispatchQueue.main.async {
                completitonBlock(data)
            }
        }
    }
    
    class func readAudioSample(from asset: AVAsset) -> Data? {
        
        var assetReader: AVAssetReader? = nil
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            print("create asset reader failed")
        }
        guard assetReader != nil else {
             return nil
        }
        
        let track = asset.tracks(withMediaType: .audio).first
        let outputSetting = [AVFormatIDKey: kAudioFormatLinearPCM,
                             AVLinearPCMIsBigEndianKey: false,
                             AVLinearPCMIsFloatKey: false,
                             AVLinearPCMBitDepthKey: 16]
            as [String : Any]
        let trackOutput = AVAssetReaderTrackOutput(track: track!, outputSettings: outputSetting)
        assetReader?.add(trackOutput)
        assetReader?.startReading()
        
        var sampleData = Data()
        while assetReader?.status == AVAssetReader.Status.reading {
            let sampleBuffer = trackOutput.copyNextSampleBuffer()
            if sampleBuffer != nil {
                // 读取track中的blockBufferRef数据
                guard let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer!) else { return nil }
                // 获取blockBuffer的长度
                let length = CMBlockBufferGetDataLength(blockBufferRef)
                // 创建一个数组来接收
                let sampleBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
                // 拷贝到这个数组
                CMBlockBufferCopyDataBytes(blockBufferRef, atOffset: 0, dataLength: length, destination: sampleBytes)
                
                sampleData.append(sampleBytes, count: length)
                CMSampleBufferInvalidate(sampleBuffer!)
                sampleBytes.deinitialize(count: length)
                
            }
        }
        if assetReader?.status == AVAssetReader.Status.completed {
            return sampleData
        } else {
            print("sample data 读取失败")
            return nil
        }
        
    }
    
    
}
