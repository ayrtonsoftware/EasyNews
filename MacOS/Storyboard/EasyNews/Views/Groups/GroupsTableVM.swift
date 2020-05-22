//
//  GroupTableVM.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation
import RealmSwift

class GroupsTableVM {
    init() {
        if let realm = MainVC.getReaderBox().realm {
            groups = realm.objects(NewsGroup.self)
        }
    }
        
    public func setSearch(text: String) {
        if let realm = MainVC.getReaderBox().realm {
            if text.count > 0 {
                groups = realm.objects(NewsGroup.self).filter("name CONTAINS [cd] '\(text)'")
            } else {
                groups = realm.objects(NewsGroup.self)
            }
        }
    }
    
    //var groups: [NewsGroup] = []
    var groups : Results<NewsGroup>?
    
//    public func getCachedGroups() -> [NewsGroup] {
//        var groups: [NewsGroup] = []
//
//        if let realm = MainVC.getReaderBox().realm {
//            groups = realm.objects(NewsGroup.self)
////            for group in realm.objects(NewsGroup.self) {
////                groups.append(group)
////            }
//        }
//        return groups
//    }
    
    public func updateGroups() {
        _ = ListGroupsCommand(reader: MainVC.CreateNewsReader())
    }
}
