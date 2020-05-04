//
//  NewsReader.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/29/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

protocol NewsReaderDelegate: class {
    func NewsReader_error(message: String)
    func NewsReader_groups(groups: [Group])
    func NewsReader_articles(articles: [String])
    func NewsReader_notification(notification: String)
}

struct Group {
    var name: String
    var first: Int
    var last: Int
    var canPost: Bool
}

class NewsReader: NSObject, StreamDelegate {
    //private var rbox: ReaderBox
    public var delegate: NewsReaderDelegate?
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var readStream: Unmanaged<CFReadStream>?
    private var writeStream: Unmanaged<CFWriteStream>?
    private var serverAddress: String
    private var port: UInt32
    private var username: String
    private var password: String
    
    //    public func getGroups() -> [NewsGroup] {
    //        var groups: [NewsGroup] = []
    //        if let realm = rbox.realm {
    //            for group in realm.objects(NewsGroup.self) {
    //                groups.append(group)
    //            }
    //        }
    //        return groups
    //    }
    
    private var _connected: Bool = false
    public var connected: Bool {
        return _connected
    }
    
    init(serverAddress: String, port: UInt32, username: String, password: String) {
        self.serverAddress = serverAddress
        self.port = port
        self.username = username
        self.password = password
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
    
    private var resultsComing = false
    private var currentOperation: String?
    private var currentGroupName: String?
    
    public func listArticles(groupName: String) {
        if !connected {
            delegate?.NewsReader_error(message: "Not connected")
            return
        }
        currentGroupName = groupName
        currentOperation = "ListGroupArticles"
        response = ""
        send(command: "LISTGROUP \(groupName)\n")
    }
    
    public func listGroups() {
        if !connected {
            delegate?.NewsReader_error(message: "Not connected")
            return
        }
        currentOperation = "ListGroups"
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
            delegate?.NewsReader_notification(notification: "Done")
            return
        }
        if buffer.starts(with: "381 PASS required") {
            send(command: "AUTHINFO pass \(password)\n")
            response = ""
            return
        }
        if buffer.starts(with: "281 Welcome To Easynews.") {
            _connected = true
            delegate?.NewsReader_notification(notification: "Connected")
            response = ""
            return
        }
        if buffer.starts(with: "502 Authentication Failed") {
            delegate?.NewsReader_notification(notification: "ConnectionFailed")
            response = ""
            return
        }
        if buffer.starts(with: "205 Goodbye") {
            close()
            delegate?.NewsReader_notification(notification: "Disconnected")
            response = ""
            return
        }
        if buffer.starts(with: "215 NewsGroups Follow") {
            print("Got 215...............")
            resultsComing = true
            response = ""
            return
        }
        if buffer.starts(with: "211 Article Numbers Follow") {
            print("Getting articles")
            resultsComing = true
            response = ""
            return
        }
    }
    
    func splitter(line: String) -> (String, String) {
        if let pos = line.range(of: "\r\n", options: .backwards) {
            let range = line.startIndex..<pos.lowerBound
            let what = line[range]
            let range2 = pos.upperBound..<line.endIndex
            let newLine = line[range2]
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
                    if !resultsComing {
                        return response
                    }
                    let (prefix, rest) = splitter(line: response)
                    response = rest
                    let lines = prefix.split(separator: "\r\n").map(String.init)
                    
                    if resultsComing && currentOperation == "ListGroupArticles" {
                        var isDone = false
                        var newArticles: [String] = []
                        if lines.count > 0 {
                            lines.forEach { (article: String) in
                                if article == "." {
                                    isDone = true
                                } else {
                                    newArticles.append(article)
                                }
                            }
                        }
                        delegate?.NewsReader_articles(articles: newArticles)
                        if isDone {
                            delegate?.NewsReader_notification(notification: "Done")
                        }
                    }
                    
                    if resultsComing && currentOperation == "ListGroups" {
                        //print(">>>>\(prefix)")
                        if lines.count > 0 {
                            var isDone = false
                            var newGroups: [Group] = []
                            lines.forEach { (name: String) in
                                if name == "." {
                                    isDone = true
                                } else {
                                    let parts = name.split(separator: " ").map(String.init)
                                    if parts.count == 4,
                                        let last = Int(parts[1]),
                                        let first = Int(parts[2]) {
                                        print(">>> name: \(parts[0])")
                                        let newGroup = Group(name: parts[0], first: first, last: last, canPost: parts[3] == "y")
                                        newGroups.append(newGroup)
                                    }
                                }
                            }
                            delegate?.NewsReader_groups(groups: newGroups)
                            if isDone {
                                delegate?.NewsReader_notification(notification: "Done")
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
}

