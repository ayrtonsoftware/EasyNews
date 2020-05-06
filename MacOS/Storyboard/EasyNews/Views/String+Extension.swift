//
//  String+Extension.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/6/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

let regex = try! NSRegularExpression(pattern: "\\(\\d+\\/\\d+\\)|\\[\\d+\\/\\d+\\]")

extension String {
    func fileNumber() -> Int {
        let range = NSRange(location: 0, length: self.utf16.count)
        let matches = regex.matches(in: self, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: range)
        if matches.count == 1 {
            let nsString = NSString(string: self)
            if let match = matches.first {
                let matchString = nsString.substring(with: match.range) as String
                var num = matchString.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                let parts = num.split(separator: "/").map(String.init)
                if parts.count == 2 {
                    return Int(parts[0]) ?? 0
                }
                return 0
            }
        }
        return 0
    }
    
    func nudeSubject() -> String {
        let range = NSRange(location: 0, length: self.utf16.count)
        let matches = regex.matches(in: self, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: range)
        if matches.count == 1 {
            let nsString = NSString(string: self)
            if let match = matches.first {
                let matchString = nsString.substring(with: match.range) as String
                let subjectMinusIndex = self.replacingOccurrences(of: matchString, with: "").trimmingCharacters(in: .whitespaces)
                return subjectMinusIndex
            }
        }
        return self
    }
}
