//
//  NSView+Extension.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

protocol LoadableNib {
    var contentView: NSView! { get }
}

extension LoadableNib where Self: NSView {

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        print("Loading NIB: \(String(describing: type(of: self)))")
        _ = nib.instantiate(withOwner: self, topLevelObjects: nil)

        contentView.autoresizingMask = [.height, .width]
        addSubview(contentView)
        contentView.frame = self.bounds
    }
}
