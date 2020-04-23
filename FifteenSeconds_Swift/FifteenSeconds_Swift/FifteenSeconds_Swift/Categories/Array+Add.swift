//
//  Array+Add.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation


extension Array {
    mutating func xf_exchangeElement(from index: Int, to toIndex: Int) {
        
        assert(index >= 0 && toIndex >= 0 && index < self.count && toIndex < self.count, "index out of range")
        
        let temp = self[index]
        self[index] = self[toIndex]
        self[toIndex] = temp
    }
}
