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

class GroupsTableView: NSTableView, NSTableViewDataSource, NSTableViewDelegate, GroupsTableVMDelegate {
    func groupsAdded() {
        reloadData()
    }
    
    private var vm: GroupsTableVM?
    public var groupsDelegate: GroupsTableDelegate?
    
    public func setViewModel(vm: GroupsTableVM) {
        self.vm = vm
        self.vm?.delegate = self
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.dataSource = self
        self.delegate = self
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count = vm?.groups.count ?? 0
        print("number of groups: \(count)")
        return count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let group = vm?.groups[self.selectedRow] {
            print("Selected: \(group.name)")
            groupsDelegate?.groupSelected(group: group)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let group = vm?.groups[row]
        
        if tableColumn?.identifier.rawValue == "progress" {
            let cell = TableProgressIndicator()
            cell.progressValue = CGFloat(group?.progress ?? 0)
            return cell
        }
        if tableColumn?.identifier.rawValue == "name" {
            let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = group?.name ?? "N/A"
            return cell
        }
        if tableColumn?.identifier.rawValue == "first" {
            let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = String(group?.first ?? 0)
            return cell
        }
        if tableColumn?.identifier.rawValue == "last" {
            let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = String(group?.last ?? 0)
            return cell
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
    }
}
