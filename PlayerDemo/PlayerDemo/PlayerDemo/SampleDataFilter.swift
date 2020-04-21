//
//  SampleDataFilter.swift
//  PlayerDemo
//
//  Created by 壹九科技1 on 2020/4/10.
//  Copyright © 2020 YJKJ. All rights reserved.
//

import UIKit

class SampleDataFilter {

    var sampleData: Data
    
    init(_ data: Data) {
        self.sampleData = data
    }
    
    func filterSample(for size: CGSize) -> [CGFloat] {
        var filterSamples = [Int]()
        /// 样本数量
        let sampleCount = sampleData.count / MemoryLayout<Int>.size
        /// 样本'箱'的尺寸, 每一个点渲染一条样本'箱'
        let binSize = sampleCount / Int(size.width)
        // 拷贝sampleData到数组|bytes|
        let bytes = UnsafeMutableBufferPointer<Int>.allocate(capacity: sampleData.count)
        let _ = sampleData.copyBytes(to: bytes)
        // 最大sample
        var maxSample: Int = 0
        // 迭代样本, 迭代步长为binsize, '箱'的尺寸
        for i in stride(from: 0, to: sampleCount - 1, by: binSize) {
            // 每个箱的数据的数组
            var sampleBin = [Int](repeating: 0, count: binSize)
            for j in 0..<binSize {
                let index = i + j
                if index < bytes.count {
                    let byte = bytes[index]
                    sampleBin[j] = byte.littleEndian
                } else {
                    sampleBin[j] = 0
                }
            }
            // 每个箱的最大数据
            let value = self.maxValue(in: sampleBin)
            // 存入结果数组
            filterSamples.append(value)
            // 获取最大值
            if value > maxSample {
                maxSample = value
            }
        }
        // 根据最大值与view的高度来决定缩放因子
        let scaleFactor = (size.height/2)/CGFloat(maxSample)
        var filteredSamples = [CGFloat]()
        for i in 0..<filterSamples.count {
            // 根据缩放因子重新计算每个样本长度
            filteredSamples.append(CGFloat(filterSamples[i]) * scaleFactor)
        }
        return filteredSamples
    }
    
    func maxValue(in values: [Int]) -> Int {
        var maxValue: Int = 0
        for i in 0..<values.count {
            if abs(values[i]) > maxValue {
                maxValue = abs(values[i])
            }
        }
        return maxValue
    }
}
