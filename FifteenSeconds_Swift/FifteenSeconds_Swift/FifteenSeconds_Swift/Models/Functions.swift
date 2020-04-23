//
//  Functions.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import CoreMedia

let TIMELINE_SECONDS: CGFloat = 15.0
let TIMELINE_WIDTH: CGFloat = 1014.0

func GetWidthFor(timeRange: CMTimeRange, scaleFactor: CGFloat) -> CGFloat {
    return CGFloat(CMTimeGetSeconds(timeRange.duration)) * scaleFactor
}

func GetOrigin(for time: CMTime) -> CGPoint {
    let seconds = CMTimeGetSeconds(time)
    return CGPoint(x: CGFloat(seconds) * (TIMELINE_WIDTH / TIMELINE_SECONDS), y: 0)
}

func GetTimeRange(for width: CGFloat, scaleFactor: CGFloat) -> CMTimeRange {
   let duration = width / scaleFactor
    return CMTimeRangeMake(start: .zero, duration: CMTimeMakeWithSeconds(Float64(duration), preferredTimescale: Int32(NSEC_PER_SEC)))
}

func GetTime(for origin: CGFloat, scaleFactor: CGFloat) -> CMTime {
    let seconds = origin / scaleFactor
    return CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: Int32(NSEC_PER_SEC))
}

func DegreesToRadians(degrees: CGFloat) -> CGFloat {
    return degrees * CGFloat(Double.pi) / 180
}

