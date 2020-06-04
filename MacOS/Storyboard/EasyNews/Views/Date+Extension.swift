//
//  Date+Extension.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/6/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

public extension Date
{
    // "2019-10-29 22:06:36 PM"
    static public func parse(string: String) -> Date?
    {
        let formats = ["yyyy-MM-dd HH:mm:ss Z",
                       "yyyy-MM-dd HH:mm:ss a",
                       "yyyy-MM-dd hh:mm:ss",
                       "yyyy-MM-dd HH:mm:ss",
                       "MM/dd/yyyy",
                       "yyyy-MM-dd",
                       "MM/dd/yyyy HH:mma",
                       "yyyy-MM-dd HH:mma",
                       "MM/dd/yyyy HH:mm:ssa",
                       "E, d MMM yyyy HH:mm:ss Z"]
        
        let formatter = DateFormatter()

        for dateFormat in formats
        {
            formatter.dateFormat = dateFormat
            if let date = formatter.date(from: string)
            {
                return date
            }
        }
        
        if string.contains(" 02:") && !string.contains(" AM") {
            return parse(string: "\(string) AM")
        }
        return nil
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func toUtcString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        // "2016-11-02 04:48:53 +0800" <-- same date, local with seconds and time zone
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcTimeZoneStr = dateFormatter.string(from: self)
        return utcTimeZoneStr
    }
    
    func utcToLocalString(format: String = "MM/dd/yyy hh:mm:ss a") -> String {
        //print("----\(self)--")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        // "2016-11-02 04:48:53 +0800" <-- same date, local with seconds and time zone
        dateFormatter.timeZone = TimeZone.current
        let localTime = dateFormatter.string(from: self)
        return localTime
    }
}
