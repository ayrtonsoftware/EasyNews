//
//  ArticlesTableView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/4/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

//class ArticleOutlineVM {
//    var article: NewsGroupArticleVM
//    var children: [NewsGroupArticleVM]
//    
//    init(article: NewsGroupArticleVM) {
//        self.article = article
//        self.children = []
//    }
//}

class ArticlesTableView: NSOutlineView, NSOutlineViewDataSource, NSOutlineViewDelegate {
    func GroupsTable_reload() {
        reloadData()
    }
    
    var vm: ArticlesTableVM?
    
    public func setViewModel(vm: ArticlesTableVM) {
        self.vm = vm
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
        if item == nil {
            return vm?.articles.count ?? 0
        }
        if let item = item as? ArticleOutlineVM {
            return item.children.count
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return vm?.articles[index]
        }
        if let item = item as? ArticleOutlineVM {
            return item.children[index]
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? ArticleOutlineVM {
            return item.children.count > 1
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        print(item)
        if let article = item as? NewsGroupArticleVM {
            if tableColumn?.identifier.rawValue == "id" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.id
                return cell
            }
            if tableColumn?.identifier.rawValue == "subject" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.subject
                return cell
            }
            if tableColumn?.identifier.rawValue == "contentType" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.contentType
                return cell
            }
        }
        if let item2 = item as? ArticleOutlineVM {
            let article = item2.article
            
            if tableColumn?.identifier.rawValue == "id" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.id
                return cell
            }
            if tableColumn?.identifier.rawValue == "subject" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.subject.nudeSubject()
                return cell
            }
            if tableColumn?.identifier.rawValue == "contentType" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.contentType
                return cell
            }
        }
        if item == nil {
            return nil
        }
        return nil
//        var article: NewsGroupArticleVM?
//
//        let group = vm?.group.articles[row]
//        if let group = group {
//            if tableColumn?.identifier.rawValue == "id" {
//                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
//                cell?.textField?.stringValue = group.id
//                return cell
//            }
//            if tableColumn?.identifier.rawValue == "subject" {
//                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
//                cell?.textField?.stringValue = group.subject
//                return cell
//            }
//            if tableColumn?.identifier.rawValue == "contentType" {
//                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
//                cell?.textField?.stringValue = group.contentType
//                return cell
//            }
        }
}
