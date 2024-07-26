//
//  Bytes+String.swift
//  Hemlock
//
//  Created by Sylvan Martin on 7/25/24.
//

import Foundation

extension [UInt8] {
    
    var hexString: String {
        self.map {
            String(format: "%02X", $0)
        }.reduce("", +)
    }
    
    init(hexString: String) {
        let paddedString = hexString.count % 2 == 1 ? hexString + "0" : hexString
        self = [UInt8](repeating: 0, count: paddedString.count / 2)
        let digits = paddedString.map { String($0) }
        
        for i in 0..<self.count {
            self[i] = UInt8(digits[2 * i] + digits[2 * i + 1], radix: 16)!
        }
    }
    
}

