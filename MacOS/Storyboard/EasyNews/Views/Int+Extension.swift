//
//  Int+Extension.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/6/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

public extension Int64 {
    func formatFileSize() -> String {
        let fsize = Float(self)
        var factor: Float = 1024.0
        if fsize < factor {
            let bs = "\(fsize) bytes"
            return bs
        }
        if fsize < factor * 1024.0 {
            let kb = Float(self) / factor
            let kbs = String(format: "%.1f KB", kb)
            return kbs
        }

        factor *= 1024.0
        if fsize < factor * 1024.0 {
            let mb = Float(self) / factor
            let mbs = String(format: "%.1f MB", mb)
            return mbs
        }

        factor *= 1024.0
        if fsize < factor * 1024.0 {
            let gb = Float(self) / factor
            let gbs = String(format: "%.1f GB", gb)
            return gbs
        }

        let bs = "\(fsize) bytes"
        return bs
    }
}

public extension UInt64 {
    func formatFileSize() -> String {
        let fsize = Float(self)
        var factor: Float = 1024.0
        if fsize < factor {
            let bs = "\(fsize) bytes"
            return bs
        }
        if fsize < factor * 1024.0 {
            let kb = Float(self) / factor
            let kbs = String(format: "%.1f KB", kb)
            return kbs
        }

        factor *= 1024.0
        if fsize < factor * 1024.0 {
            let mb = Float(self) / factor
            let mbs = String(format: "%.1f MB", mb)
            return mbs
        }

        factor *= 1024.0
        if fsize < factor * 1024.0 {
            let gb = Float(self) / factor
            let gbs = String(format: "%.1f GB", gb)
            return gbs
        }

        let bs = "\(fsize) bytes"
        return bs
    }
}

public extension Int
{
    static let formats = ["^\\d*$"]
    static func parse(string: String) -> Int?
    {
        for format in formats
        {
            if string.regexMatch(pattern: format)
            {
                return Int(string)
            }
        }
        return nil
    }
    
    func formatFileSize() -> String {
        let fsize = Float(self)
        var factor: Float = 1024.0
        if fsize < factor {
            let bs = "\(fsize) bytes"
            return bs
        }
        if fsize < factor * 1024.0 {
            let kb = Float(self) / factor
            let kbs = String(format: "%.1f KB", kb)
            return kbs
        }
        
        factor *= 1024.0
        if fsize < factor * 1024.0 {
            let mb = Float(self) / factor
            let mbs = String(format: "%.1f MB", mb)
            return mbs
        }
        
        factor *= 1024.0
        if fsize < factor * 1024.0 {
            let gb = Float(self) / factor
            let gbs = String(format: "%.1f GB", gb)
            return gbs
        }
        
        let bs = "\(fsize) bytes"
        return bs
    }
}

