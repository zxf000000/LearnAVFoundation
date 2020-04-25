//
//  CompositionBuilderFactory.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

class CompositionBuilderFactory {
    func builder(for timeline: TimeLine) -> CompositionBuilder? {
        if timeline.isSimpleTimeline() {
            return BasicCompositionBuilder(timeline: timeline)
        }
        return nil
    }
}
