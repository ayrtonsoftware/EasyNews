//
//  GroupsTableView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

protocol GroupsTableDelegate {
    func groupSelected(group: NewsGroupVM)
}

class GroupsTableView: NSTableView, NSTableViewDataSource, NSTableViewDelegate /*, GroupsTableVMDelegate*/ {
    func GroupsTable_reload() {
        reloadData()
    }
    
    private var vm: GroupsTableVM?
    public var groupsDelegate: GroupsTableDelegate?
    
    public func setViewModel(vm: GroupsTableVM) {
        self.vm = vm
    }

    @objc private func GroupUpdated(_ notification: Notification) {
        reloadData()
    }

    @objc private func GroupAdded(_ notification: Notification) {
        reloadData()
        scrollToEndOfDocument(nil)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GroupAdded(_:)),
                                               name: NotificationGroupAdded(),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GroupUpdated(_:)),
                                               name: NotificationGroupUpdated(),
                                               object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
        addObservers()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.dataSource = self
        self.delegate = self
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count = vm?.groups.count ?? 0
        return count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let group = vm?.groups[self.selectedRow] {
            groupsDelegate?.groupSelected(group: group)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let group = vm?.groups[row]
        if let group = group {
            if tableColumn?.identifier.rawValue == "progress" {
                let cell = TableProgressIndicator()
                cell.progressValue = CGFloat(group.progress)
                return cell
            }
            if tableColumn?.identifier.rawValue == "name" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = group.name
                return cell
            }
            if tableColumn?.identifier.rawValue == "first" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = String(group.first)
                return cell
            }
            if tableColumn?.identifier.rawValue == "last" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = String(group.last)
                return cell
            }
            if tableColumn?.identifier.rawValue == "loaded" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = String(group.articles.count)
                return cell
            }
        }
        return nil
    }
}
