//
//  GroupTableVM.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

class GroupsTableVM {
    init() {
        groups.append(contentsOf: getCachedGroups().map(NewsGroupVM.init))
    }
        
    var groups: [NewsGroupVM] = []

    public func getCachedGroups() -> [NewsGroup] {
        var groups: [NewsGroup] = []
        
        if let realm = MainVC.getReaderBox().realm {
            for group in realm.objects(NewsGroup.self) {
                groups.append(group)
            }
        }
        return groups
    }
    
//    public func updateGroup(vm: NewsGroupVM) {
//        groups = groups.map { (evm: NewsGroupVM) -> NewsGroupVM in
//            if evm.name == vm.name {
//                let mod = evm
//                mod.articles = vm.articles
//                return mod
//            }
//            return evm
//        }
//    }
    
    public func updateGroups() {
        _ = ListGroupsCommand(rbox: MainVC.getReaderBox(), reader: MainVC.CreateNewsReader()/*, delegate: self*/)
    }
}

//extension GroupsTableVM: ListGroupsDelegate {
//    func ListGroups_refresh() {
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: NotificationGroupAdded(), object: nil)
//        }
//    }
//
//    func ListGroups_groupsAdded(newGroups: [NewsGroup]) {
//        groups.append(contentsOf: newGroups.map(NewsGroupVM.init))
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: NotificationGroupAdded(), object: nil)
//        }
//    }
//
//    func ListGroups_done(status: String) {
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: NotificationGroupAdded(), object: nil)
//        }
//    }
//}
