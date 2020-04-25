//
//  TimelineItemViewModel.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import CoreMedia

class TimelineItemViewModel {
    var widthInTimeline: CGFloat? {
        get {
            return GetWidthFor(timeRange: (timelineItem?.timeRange)!, scaleFactor: TIMELINE_WIDTH / TIMELINE_SECONDS)
        }
    }
    var maxWidthInTimeline: CGFloat?
    var positionInTimeline: CGPoint?
    
    var timelineItem: TimeLineItem?
    
    init(timeline: TimeLineItem) {
        self.timelineItem = timeline
        let maxTimeRange = CMTimeRangeMake(start: .zero, duration: timelineItem?.timeRange?.duration ?? .zero)
        maxWidthInTimeline = GetWidthFor(timeRange: maxTimeRange, scaleFactor: TIMELINE_WIDTH / TIMELINE_SECONDS)
    }
    func udpateTimelineItem() {
        if positionInTimeline?.x ?? 0 > 0 {
            let startTime = GetTime(for: positionInTimeline?.x ?? 0, scaleFactor: TIMELINE_WIDTH / TIMELINE_SECONDS)
            timelineItem?.startTimeInTimeLine = startTime
        }
        timelineItem?.timeRange = GetTimeRange(for: widthInTimeline!, scaleFactor: TIMELINE_WIDTH / TIMELINE_SECONDS)
    }
}
