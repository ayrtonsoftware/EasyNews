//
//  ViewController.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/28/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
//import SwiftSocket

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var reader: NewsReader = NewsReader(serverAddress: "news.easynews.com", port: 443, username: "nova1138", password: "Q@qwestar72Poi")
    
    @IBAction func onOpen(sender: NSButton) {
        reader.delegate = self
        reader.open()
    }

    @IBAction func onGroups(sender: NSButton) {
        reader.list()
    }

    @IBAction func onClose(sender: NSButton) {
        reader.quit()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension ViewController: NewsReaderDelegate {
    func error(message: String) {
        print("EasyNews: Error : \(message)")
    }
    
    func groups(names: [String]) {
        print("List of Groups:")
        names.forEach { (name: String) in
            print(">>> name: \(name)")
        }
    }
    
    func connected() {
        print("EasyNews: connected")
    }
    
    func connectionFailed() {
        print("EasyNews: connection failed")
    }
    
    func disconnected() {
        print("EasyNews: disconnected")
    }
    
    
}
class OldViewController: NSViewController, StreamDelegate {
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    
    func setupNetworkCommunication() {
        // 1
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        // 2
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "news.easynews.com" as CFString,
                                           443,
                                           &readStream,
                                           &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        inputStream.delegate = self
        //outputStream.delegate = self
        inputStream.open()
        outputStream.open()
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if aStream == inputStream {
            print("event code: [\(eventCode)]")
            switch eventCode {
            case .hasBytesAvailable:
                print("new message received")
                readAvailableBytes(stream: aStream as! InputStream)
                
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
        if aStream == outputStream {
            print("event code: [\(eventCode)]")
            switch eventCode {
            case .hasBytesAvailable:
                print("outputStream: new message received")
            case .endEncountered:
                print("outputStream: new message received")
            case .errorOccurred:
                print("outputStream: error occurred")
            case .hasSpaceAvailable:
                print("outputStream: has space available")
            case .hasBytesAvailable:
                print("outputStream: has bytes available")
            default:
                print("outputStream: some other event...")
            }
        }
    }
    
    let maxReadLength = 4096
    
    var buffer: UnsafeMutablePointer<UInt8>?
    //var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
    
    
    private func readAvailableBytes(stream: InputStream) {
        if buffer == nil {
            buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
            print(buffer)
        }
        ///var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        print("Buffer \(buffer)")
        if let buffer = self.buffer {
            //let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
            while stream.hasBytesAvailable {
                let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
                print(">>>>> number read \(numberOfBytesRead)")
                if numberOfBytesRead < 0, let error = stream.streamError {
                    print(error)
                    break
                }
                
                // Construct the message object
                print("Number of Bytes Read \(numberOfBytesRead)")
                if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                    // Notify interested parties
                    print("Message: \(message)")
                    if message.contains("Welcome!") {
                        send(command: "AUTHINFO user nova1138\n")
                    }
                    if message.contains("PASS required") {
                        send(command: "AUTHINFO pass Q@qwestar72Poi\n")
                    }
                    if message.contains("281 Welcome To Easynews.") {
                        send(command: "LIST\n")
                    }
                }
            }
        }
    }
    
    func send(command: String) {
        DispatchQueue.global(qos: .background).async {
            print("Send Command: [\(command)]")
            let data = command.data(using: .utf8)!
            _ = data.withUnsafeBytes {
                guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    print("Error joining chat")
                    return
                }
                print("Bytes to send \(data.count)")
                let bytesWritten = self.outputStream.write(pointer, maxLength: data.count)
                print("Bytes written \(bytesWritten)")
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupNetworkCommunication()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

