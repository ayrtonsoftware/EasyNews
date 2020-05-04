//
//  GroupTableVM.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

protocol GroupsTableVMDelegate: class {
    func GroupsTable_reload()
}

class GroupsTableVM {
    public var delegate: GroupsTableVMDelegate?
    private var rbox: ReaderBox
    
    init(rbox: ReaderBox) {
        self.rbox = rbox
        groups.append(contentsOf: getCachedGroups().map(NewsGroupVM.init))

    }
        
    var groups: [NewsGroupVM] = []

    public func getCachedGroups() -> [NewsGroup] {
        var groups: [NewsGroup] = []
        if let realm = rbox.realm {
            for group in realm.objects(NewsGroup.self) {
                groups.append(group)
            }
        }
        return groups
    }
    
    public func updateGroup(vm: NewsGroupVM) {
        groups = groups.map { (evm: NewsGroupVM) -> NewsGroupVM in
            if evm.name == vm.name {
                var mod = evm
                mod.articles = vm.articles
                return mod
            }
            return evm
        }
    }
    
    public func updateGroups() {
        _ = ListGroupsCommand(rbox: rbox, reader: MainVC.CreateNewsReader(), delegate: self)
    }
}

extension GroupsTableVM: ListGroupsDelegate {
    func ListGroups_refresh() {
        delegate?.GroupsTable_reload()
    }
    
    func ListGroups_groupsAdded(newGroups: [NewsGroup]) {
        groups.append(contentsOf: newGroups.map(NewsGroupVM.init))
        delegate?.GroupsTable_reload()
    }
    
    func ListGroups_done(status: String) {
        print("List Groups: \(status)")
    }
}
