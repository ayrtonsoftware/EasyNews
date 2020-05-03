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
    
    func groups(newGroups: [NewsGroup]) {
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
    
    init(reader: NewsReader, delegate: ListGroupsDelegate) {
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
    
    func groups(newGroups: [NewsGroup]) {
        delegate?.ListGroups_groupsAdded(newGroups: newGroups)
    }
}

class GroupsTableVM {
    public var delegate: GroupsTableVMDelegate?
    
    private var reader: NewsReader
    
    init(reader: NewsReader) {
        self.reader = reader
        groups.append(contentsOf: reader.getGroups().map(NewsGroupVM.init))

    }
        
    var groups: [NewsGroupVM] = []
    
    public func getGroups() {
        reader.delegate = ListGroupsCommand(reader: reader, delegate: self)
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
