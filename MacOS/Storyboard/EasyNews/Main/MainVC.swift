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
    private var reader: NewsReader = NewsReader(serverAddress: "news.easynews.com", port: 443, username: "nova1138", password: "Q@qwestar72Poi")
    private var rbox = ReaderBox()
    
    func groupSelected(group: NewsGroupVM) {
        if let tab = tabCache[group.name] {
            tabs.selectTabViewItem(tab)
        } else {
            let newItem: NSTabViewItem = NSTabViewItem(identifier: group.name)
            newItem.view?.autoresizesSubviews = true
            let groupView = GroupTabView(frame: CGRect.zero)
            groupView.autoresizingMask = [.height, .width]
            newItem.label = group.name
            newItem.view = groupView
            tabCache[group.name] = newItem
            tabs.addTabViewItem(newItem)
        }
    }
    
    var groupsVM: GroupsTableVM!
    
    @IBOutlet var groupsTable: GroupsTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        groupsVM = GroupsTableVM(reader: reader, rbox: rbox)
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
