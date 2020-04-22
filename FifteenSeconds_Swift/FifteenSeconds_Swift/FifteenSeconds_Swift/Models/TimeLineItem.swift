//
//  TimeLineItem.swift
//  FifteenSeconds_Swift
//
//  Created by 壹九科技1 on 2020/4/22.
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation
import CoreMedia

class TimeLineItem {
    var timeRange: CMTimeRange?
    var startTimeInTimeLine: CMTime?
    
    init() {
        timeRange = .invalid
        startTimeInTimeLine = .invalid
    }
}
