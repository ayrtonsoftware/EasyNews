//
//  AppDelegate.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/28/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        let storyboard = NSStoryboard(name: "ThreadPlay", bundle: nil)
//        if let window = storyboard.instantiateController(withIdentifier: "ThreadPlay") as? NSWindowController {
//            window.showWindow(window)
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

