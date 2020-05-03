//
//  AppDelegate.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/30/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var reader: NewsReader!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        reader = NewsReader(serverAddress: "news.easynews.com",
                            port: 443,
                            username: "nova1138",
                            password: "Q@qwestar72Poi")
        let contentView = ContentView(groups: reader.getGroups().map(NewsGroupVM.init))
        
        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

