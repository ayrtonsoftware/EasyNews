//
//  ArticlesTableView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/4/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

class ArticlesTableView: NSTableView, NSTableViewDataSource, NSTableViewDelegate {
    func GroupsTable_reload() {
        reloadData()
    }
    
    private var vm: ArticlesTableVM?
    
    public func setViewModel(vm: ArticlesTableVM) {
        self.vm = vm
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.dataSource = self
        self.delegate = self
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count = vm?.group.articles.count ?? 0
        print("number of articles: \(count)")
        return count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let article = vm?.group.articles[self.selectedRow] {
            print("Selected: \(article.id)")
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let group = vm?.group.articles[row]
        if let group = group {
            if tableColumn?.identifier.rawValue == "id" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = group.id
                return cell
            }
            if tableColumn?.identifier.rawValue == "subject" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = group.subject
                return cell
            }
            if tableColumn?.identifier.rawValue == "contentType" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = group.contentType
                return cell
            }
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
    }
}
