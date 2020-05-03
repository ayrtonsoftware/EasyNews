//
//  GroupView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

class GroupTabView: NSView, LoadableNib {
    @IBOutlet var contentView: NSView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        //self.wantsLayer = true
        //self.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        //self.wantsLayer = true
        //self.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
}
