//
//  ViewController.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/28/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
//import SwiftSocket

class MainVC: NSViewController, GroupsTableDelegate {
    @IBOutlet var tabs: NSTabView!
    private var tabCache: [String: NSTabViewItem] = [:]
    
    static func CreateNewsReader() -> NewsReader {
        var reader: NewsReader = NewsReader(serverAddress: "news.easynews.com", port: 443, username: "nova1138", password: "Q@qwestar72Poi")
        return reader
    }
    
    private static var rbox = ReaderBox()
    
    static func getReaderBox() -> ReaderBox {
        return MainVC.rbox
    }
    
    func reload() {
        groupsTable.reloadData()
    }
    
    func groupUpdated(group: NewsGroupVM) {
        print("group updated: \(group.name)")
        groupsVM.updateGroup(vm: group)
        groupsTable.reloadData()
    }

    func groupSelected(group: NewsGroupVM) {
        if let tab = tabCache[group.name] {
            tabs.selectTabViewItem(tab)
        } else {
            let newItem: NSTabViewItem = NSTabViewItem(identifier: group.name)
            newItem.view?.autoresizesSubviews = true
            let groupView = GroupTabView(group: group, groupsTableDelegate: self, frame: CGRect.zero)
            groupView.autoresizingMask = [.height, .width]
            newItem.label = group.name
            newItem.view = groupView
            tabCache[group.name] = newItem
            tabs.addTabViewItem(newItem)
            tabs.selectTabViewItem(newItem)
        }
    }
    
    var groupsVM: GroupsTableVM!
    
    @IBOutlet var groupsTable: GroupsTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        groupsVM = GroupsTableVM(rbox: MainVC.getReaderBox())
        groupsTable.setViewModel(vm: groupsVM)
        groupsTable.groupsDelegate = self
    }
    
    @IBAction func onRefreshGroups(sender: NSButton) {
        self.groupsVM.updateGroups()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            print("MainVC::representedObject")
        }
    }
}
