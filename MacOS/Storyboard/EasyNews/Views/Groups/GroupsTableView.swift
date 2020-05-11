//
//  GroupsTableView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
import RealmSwift

protocol GroupsTableDelegate {
    func groupSelected(group: NewsGroup)
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
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    @objc private func GroupsAdded(_ notification: Notification) {
        DispatchQueue.main.async {
            self.reloadData()
        }
//        DispatchQueue.main.sync { [weak self] in
//            if let self = self {
//                if let groupRefs = notification.object as? [ThreadSafeReference<NewsGroup>] {
//                    let start = Date()
//                    let rbox = MainVC.getReaderBox()
//                    if let realm = rbox.realm {
//                        groupRefs.forEach { (groupRef: ThreadSafeReference<NewsGroup>) in
//                            if let group: NewsGroup = realm.resolve(groupRef) {
//                                self.vm?.groups.append(group)
//                            }
//                        }
//                    }
//                    let end = Date()
//                    let elapsed = end.timeIntervalSince(start)
//                    print("-------> Groups Added ---> \(elapsed)")
//                    self.reloadData()
//                }
//            }
//        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GroupsAdded(_:)),
                                               name: NotificationGroupsAdded(),
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
        if let result: Results<NewsGroup> = vm?.groups {
            return result.count
        }
        //let count = vm?.groups.count ?? 0
        //return count
        return 0
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let result: Results<NewsGroup> = vm?.groups {
            
        }

        //if let group = vm?.groups[self.selectedRow] {
        //    groupsDelegate?.groupSelected(group: group)
        //}
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let result: Results<NewsGroup> = vm?.groups,
            let group: NewsGroup = result[row] {
            if tableColumn?.identifier.rawValue == "progress" {
                let cell = TableProgressIndicator()
                cell.progressValue = 0
                return cell
            }
            if tableColumn?.identifier.rawValue == "name" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = group.name
                return cell
            }
            if tableColumn?.identifier.rawValue == "first" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = "\(group.first.value ?? 0)"
                return cell
            }
            if tableColumn?.identifier.rawValue == "last" {
                let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = "\(group.last.value ?? 0)"
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
