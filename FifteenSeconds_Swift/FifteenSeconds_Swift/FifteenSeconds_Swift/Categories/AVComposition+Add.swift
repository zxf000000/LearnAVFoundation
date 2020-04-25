//
//  AVComposition+Add.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation


extension AVComposition {
    func writeToFile(path: String, atomically: Bool) -> Bool {
        let dic = dictionaryRepresentation()
        return (dic as NSDictionary).write(toFile: path, atomically: atomically)
    }
    func writeToURL(url: URL, atomically: Bool) -> Bool {
        let dic = dictionaryRepresentation()
        return (dic as NSDictionary).write(to: url, atomically: atomically)
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        var dic = [String: Any]()
        var trackID: String?
        for track in self.tracks {
            trackID = "track_\(track.trackID)"
            dic[trackID!] = dictionaryForTrack(track: track)
        }
        return dic
    }
    
    func dictionaryForTrack(track: AVCompositionTrack) -> Dictionary<String, Any> {
        var segments = [[String: Any]]()
        for segment in track.segments {
            segments.append(dictionaryForSegment(segment: segment))
        }
        var dic = [String: Any]()
        dic["trackID"] = track.trackID
        dic["mediaType"] = track.mediaType
        dic["segments"] = segments
        return dic
    }
    
    func dictionaryForSegment(segment: AVCompositionTrackSegment) -> Dictionary<String, Any> {
        var dic = [String: Any]()
        dic["sourceTrackID"] = segment.sourceTrackID
        dic["sourceURL"] = stringForSourceURL(url: segment.sourceURL!)
        let sourceTimeRange = segment.timeMapping.source
        let targetTimeRange = segment.timeMapping.target
        dic["sourceTimeRange"] = dictionaryFor(timeRange: sourceTimeRange)
        dic["targetTimeRange"] = dictionaryFor(timeRange: targetTimeRange)
        dic["empty"] = segment.isEmpty
        return dic
    }
    
    func stringForSourceURL(url: URL) -> String {
        return url.absoluteString
    }
    
    func dictionaryFor(timeRange: CMTimeRange) -> Dictionary<String, Any> {
        return CMTimeRangeCopyAsDictionary(timeRange, allocator: nil) as! Dictionary<String, Any>
    }
}



