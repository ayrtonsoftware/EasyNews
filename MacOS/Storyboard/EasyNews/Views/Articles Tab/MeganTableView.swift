//
//  MeganTableView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/11/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
import RealmSwift

class MeganTableView: NSOutlineView, NSOutlineViewDataSource, NSOutlineViewDelegate {
    private var group: NewsGroup?
    private var result: Results<NewsGroupArticle>?
    
    public func setGroup(group: NewsGroup) {
        self.group = group
        let rbox = MainVC.getReaderBox()
        if let realm = rbox.realm {
            realm.beginWrite()
            var art = NewsGroupArticle()
            art.group = group
            art.subject = "This is a test"
            art.size.value = 10000
            realm.add(art)
            group.articles.append(art)
            try! realm.commitWrite()
            result = realm.objects(NewsGroupArticle.self)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.dataSource = self
        self.delegate = self
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return NewsGroupArticle()
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        return nil
    }
}
