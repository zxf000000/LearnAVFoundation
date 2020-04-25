//
//  TimelineBuilder.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class TimelineBuilder {
    class func buildTimeline(with mediaItems: [[TimelineItemViewModel]]) -> TimeLine {
        let timeline = TimeLine()
        timeline.videos = buildVideoItems(viewModels: mediaItems[MediaTrackType.video.rawValue])
        timeline.transitons = buildTransitions(viewModels: mediaItems[MediaTrackType.video.rawValue])
        timeline.voiceOvers = buildMediaItems(adaptItems: mediaItems[MediaTrackType.commontary.rawValue])
        timeline.musicItems = buildMediaItems(adaptItems: mediaItems[MediaTrackType.music.rawValue])
        timeline.titles = buildMediaItems(adaptItems: mediaItems[MediaTrackType.title.rawValue])
        return timeline
    }
    
    private class func buildMediaItems(adaptItems: [TimelineItemViewModel]) -> [TimeLineItem] {
        var items = [TimeLineItem]()
        for adaptor in adaptItems {
            adaptor.udpateTimelineItem()
            items.append(adaptor.timelineItem!)
            
        }
        return items
    }
    
    private class func buildTransitions(viewModels: [Any]) -> [VideoTransition] {
        var items = [VideoTransition]()
        
        for item in viewModels {
            if let aItem = item as? VideoTransition {
                items.append(aItem)
            }
        }
        return items
    }
    
    private class func buildVideoItems(viewModels: [Any]) -> [MediaItem] {
        var items = [MediaItem]()
        for model in viewModels {
            if let aModel = model as? TimelineItemViewModel,
                let item = aModel.timelineItem as? MediaItem {
                aModel.udpateTimelineItem()
                items.append(item)
            }
        }
        return items
    }

    
}
