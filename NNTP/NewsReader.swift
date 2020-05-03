//
//  NewsReader.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/29/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

protocol NewsReaderDelegate: class {
    func connected()
    func connectionFailed()
    func disconnected()
    func error(message: String)
    func groups(newGroups: [NewsGroup])
    func done()
}

class NewsReader: NSObject, StreamDelegate {
    private var rbox: ReaderBox
    public var delegate: NewsReaderDelegate?
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var readStream: Unmanaged<CFReadStream>?
    private var writeStream: Unmanaged<CFWriteStream>?
    private var serverAddress: String
    private var port: UInt32
    private var username: String
    private var password: String
    
    public func getGroups() -> [NewsGroup] {
        var groups: [NewsGroup] = []
        if let realm = rbox.realm {
            for group in realm.objects(NewsGroup.self) {
                groups.append(group)
            }
        }
        return groups
    }
    
    private var _connected: Bool = false
    public var connected: Bool {
        return _connected
    }
    
    init(serverAddress: String, port: UInt32, username: String, password: String) {
        rbox = ReaderBox()
        self.serverAddress = serverAddress
        self.port = port
        self.username = username
        self.password = password
        if let _ = rbox.realm {
            print("Open Realm")
        }
    }
    
    var isOpen: Bool {
        return inputStream != nil && outputStream != nil
    }
    
    // https://stackoverflow.com/questions/15632086/running-nsstream-in-background-thread
    func open() {
        if isOpen {
            return
        }
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "news.easynews.com" as CFString,
                                           443,
                                           &readStream,
                                           &writeStream)
        if let read = readStream, let write = writeStream {
            inputStream = read.takeRetainedValue()
            outputStream = write.takeRetainedValue()
            inputStream?.schedule(in: .current, forMode: .common)
            outputStream?.schedule(in: .current, forMode: .common)
            inputStream?.delegate = self
            inputStream?.open()
            outputStream?.open()
        } else {
            inputStream = nil
            outputStream = nil
        }
    }
    
    public func close() {
        if isOpen {
            inputStream?.close()
            outputStream?.close()
            inputStream = nil
            outputStream = nil
        }
    }
    
    public func quit() {
        if isOpen {
            send(command: "quit\n")
        }
    }
    
    private var currentOperation: String?
        
    public func listGroups() {
        if !connected {
            delegate?.error(message: "Not connected")
            return
        }
        currentOperation = "list"
        response = ""
        send(command: "LIST\n")
    }
    
    private func processResponse(buffer: String) {
        //print("Response: \(response)")
        if buffer.starts(with: "200 news.easynews.com Welcome!") {
            send(command: "AUTHINFO user \(username)\n")
            response = ""
            return
        }
        if buffer == "." {
            delegate?.done()
            return
        }
        if buffer.starts(with: "381 PASS required") {
            send(command: "AUTHINFO pass \(password)\n")
            response = ""
            return
        }
        if buffer.starts(with: "281 Welcome To Easynews.") {
            _connected = true
            delegate?.connected()
            response = ""
            return
        }
        if buffer.starts(with: "502 Authentication Failed") {
            delegate?.connectionFailed()
            response = ""
            return
        }
        if buffer.starts(with: "205 Goodbye") {
            close()
            delegate?.disconnected()            
            response = ""
            return
        }
        if buffer.starts(with: "215 NewsGroups Follow") {
            print("Got 215...............")
            response = ""
            return
        }
    }
    
    func splitter(line: String) -> (String, String) {
        if let pos = line.range(of: "\r\n", options: .backwards) {
            //line.substring(to: pos)
            print(pos)
            print(pos.self)
            let range = line.startIndex..<pos.lowerBound
            let what = line[range]
            //print("[\(what)]")
            
            let range2 = pos.upperBound..<line.endIndex
            let newLine = line[range2]
            //print("[\(newLine)]")
            //print("----")
            return (String(what), String(newLine))
        }
        return (line, "")
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if aStream == inputStream {
            print("event code: [\(eventCode)]")
            switch eventCode {
            case .hasBytesAvailable:
                print("new message received")
                if let response = readAvailableBytes(stream: aStream as! InputStream) {
                    processResponse(buffer: response)
                }
            case .endEncountered:
                print("new message received")
            case .errorOccurred:
                print("error occurred")
            case .hasSpaceAvailable:
                print("has space available")
            case .hasBytesAvailable:
                print("has bytes available")
            default:
                print("some other event...")
            }
        }
    }
    
    let maxReadLength = 4096
    var buffer: UnsafeMutablePointer<UInt8>?
    var response: String = ""
    
    private func readAvailableBytes(stream: InputStream) -> String? {
        guard let inputStream = self.inputStream else {
            return nil
        }
        if self.buffer == nil {
            self.buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        }
        if let buffer = self.buffer {
            //var response: String = ""
            while stream.hasBytesAvailable {
                let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
                if numberOfBytesRead < 0, let error = stream.streamError {
                    print(error)
                    break
                }
                if let output = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                    response.append(output)
                    //print("Bytes Read: \(numberOfBytesRead) now \(response.count)")
                    //print(output)
                    if connected && currentOperation == "list" {
                        let (prefix, rest) = splitter(line: response)
                        response = rest
                        let names = prefix.split(separator: "\r\n").map(String.init)
                        //print(">>>>\(prefix)")
                        if names.count > 0 {
                            var isDone = false
                            rbox.realm?.beginWrite()
                            var newGroups: [NewsGroup] = []
                            names.forEach { (name: String) in
                                if name == "." {
                                    isDone = true
                                } else {
                                    let parts = name.split(separator: " ").map(String.init)
                                    if parts.count == 4,
                                        let last = Int(parts[1]),
                                        let first = Int(parts[2]) {
                                        print(">>> name: \(parts[0])")
                                        if let newGroup = rbox.findOrCreateGroup(name: parts[0], first: first, last: last, canPost: parts[3] == "y") {
                                            newGroups.append(newGroup)
                                        }
                                    }
                                }
                            }
                            do {
                                try rbox.realm?.commitWrite()
                            }
                            catch {
                                print("Realm error \(error)")
                            }
                            delegate?.groups(newGroups: newGroups)
                            if isDone {
                                delegate?.done()
                            }
                        }
                    }
                }
            }
            return response
        }
        return nil
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> String? {
        if let message = String(
            bytesNoCopy: buffer,
            length: length,
            encoding: .utf8,
            freeWhenDone: false) {
            return message
        }
        return nil
    }
    
    func send(command: String) {
        //DispatchQueue.global(qos: .background).async {
            if let outputStream = self.outputStream {
                print("Send Command: [\(command)]")
                let data = command.data(using: .utf8)!
                _ = data.withUnsafeBytes {
                    guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                        print("Error")
                        return
                    }
                    print("Bytes to send \(data.count)")
                    let bytesWritten = outputStream.write(pointer, maxLength: data.count)
                    print("Bytes written \(bytesWritten)")
                }
            }
        }
    //}
}
