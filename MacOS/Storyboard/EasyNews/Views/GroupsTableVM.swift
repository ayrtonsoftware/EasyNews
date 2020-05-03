//
//  GroupTableVM.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

protocol GroupsTableVMDelegate: class {
    func groupsAdded()
}

/******************************************************************************/
/******************************************************************************/

class ListGroupArticlesCommand: NewsReaderDelegate {
    var reader: NewsReader
    
    init(reader: NewsReader, group: NewsGroupVM) {
        self.reader = reader
        reader.open()
    }
    
    func connected() {
        self.reader.listGroups()
    }
    
    func done() {
        print("Done getting list")
       reader.close()
    }
    
    func connectionFailed() {
    }
    
    func disconnected() {
    }
    
    func error(message: String) {
    }
    
    func groups(groups: [Group]) {
    }
}

/******************************************************************************/
/******************************************************************************/

protocol ListGroupsDelegate: class {
    func ListGroups_groupsAdded(newGroups: [NewsGroup])
    func ListGroups_done(status: String)
}

class ListGroupsCommand: NewsReaderDelegate {
    var reader: NewsReader
    var delegate: ListGroupsDelegate?
    private var rbox: ReaderBox
    
    init(rbox: ReaderBox, reader: NewsReader, delegate: ListGroupsDelegate) {
        self.rbox = rbox
        self.reader = reader
        self.delegate = delegate
        reader.open()
    }
    
    func connected() {
        self.reader.listGroups()
    }
    
    func done() {
        print("Done getting list")
       reader.close()
        delegate?.ListGroups_done(status: "Done")
    }
    
    func connectionFailed() {
        delegate?.ListGroups_done(status: "Failed")
    }
    
    func disconnected() {
        delegate?.ListGroups_done(status: "Disconnected")
    }
    
    func error(message: String) {
        delegate?.ListGroups_done(status: message)
    }
    
    func groups(groups: [Group]) {
        rbox.realm?.beginWrite()
        var newGroups: [NewsGroup] = []
        
        groups.forEach { (group: Group) in
            if let newGroup = rbox.findOrCreateGroup(name:group.name, first: group.first, last: group.last, canPost: group.canPost) {
                newGroups.append(newGroup)
            }
        }
        
        do {
            try rbox.realm?.commitWrite()
        }
        catch {
            print("Realm error \(error)")
        }
        delegate?.ListGroups_groupsAdded(newGroups: newGroups)
    }
}

class GroupsTableVM {
    public var delegate: GroupsTableVMDelegate?
    private var reader: NewsReader
    private var rbox: ReaderBox
    
    init(reader: NewsReader, rbox: ReaderBox) {
        self.reader = reader
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
    
    public func updateGroups() {
        reader.delegate = ListGroupsCommand(rbox: rbox, reader: reader, delegate: self)
    }
}

extension GroupsTableVM: ListGroupsDelegate {
    func ListGroups_groupsAdded(newGroups: [NewsGroup]) {
        groups.append(contentsOf: newGroups.map(NewsGroupVM.init))
        delegate?.groupsAdded()
    }
    
    func ListGroups_done(status: String) {
        print("List Groups: \(status)")
    }
}
