//
//  String+Add.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation


extension String {
    func stringByMatchingRegex(regex: String, capture: Int) -> String {
        let expression = try! NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.init(rawValue: 0))
        let result = expression.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, self.count))
        if (result?.numberOfRanges)! > capture {
            let range = result?.range(at: capture)
            var str = ""
            for (index, chara) in self.enumerated() {
                if index == range?.location {
                    str = String([chara])
                } else if index < (range?.location)! + (range?.length)! {
                    str.append(chara)
                }
            }
        }
        return ""
    }
}
