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
    func groups(names: [String])
}

class NewsReader: NSObject, StreamDelegate {
    public var delegate: NewsReaderDelegate?
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var readStream: Unmanaged<CFReadStream>?
    private var writeStream: Unmanaged<CFWriteStream>?
    private var serverAddress: String
    private var port: UInt32
    private var username: String
    private var password: String
    
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
    
    private func close() {
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
    
    public func list() {
        if !connected {
            delegate?.error(message: "Not connected")
            return
        }
        currentOperation = "list"
        send(command: "LIST\n")
    }
    
    private func processResponse(response: String) {
        print("Response: \(response)")
        if response.starts(with: "200 news.easynews.com Welcome!") {
            send(command: "AUTHINFO user \(username)\n")
        }
        if response.starts(with: "381 PASS required") {
            send(command: "AUTHINFO pass \(password)\n")
        }
        if response.starts(with: "281 Welcome To Easynews.") {
            _connected = true
            delegate?.connected()
        }
        if response.starts(with: "502 Authentication Failed") {
            delegate?.connectionFailed()
        }
        if response.starts(with: "205 Goodbye") {
            close()
            delegate?.disconnected()            
        }
        if response.count > 0 && currentOperation == "list" {
            currentOperation = nil
            let groups = response.split(separator: "\n").map(String.init)
            delegate?.groups(names: groups)
        }
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if aStream == inputStream {
            print("event code: [\(eventCode)]")
            switch eventCode {
            case .hasBytesAvailable:
                print("new message received")
                if let response = readAvailableBytes(stream: aStream as! InputStream) {
                    processResponse(response: response)
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
    
    private func readAvailableBytes(stream: InputStream) -> String? {
        guard let inputStream = self.inputStream else {
            return nil
        }
        if self.buffer == nil {
            self.buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        }
        if let buffer = self.buffer {
            var response: String = ""
            while stream.hasBytesAvailable {
                let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
                if numberOfBytesRead < 0, let error = stream.streamError {
                    print(error)
                    break
                }
                if let output = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                    response.append(output)
                    print("Bytes Read: \(numberOfBytesRead) now \(response.count)")
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
        DispatchQueue.global(qos: .background).async {
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
}
