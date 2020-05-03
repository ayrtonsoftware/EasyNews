//
//  GroupsTableView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

class ProgressCell: NSTableCellView {
}

class GroupsTableView: NSTableView, NSTableViewDataSource, NSTableViewDelegate {
    private var vm: GroupsTableVM?
    
    public func setViewModel(vm: GroupsTableVM) {
        self.vm = vm
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
