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

class GroupsTableVM: NewsReaderDelegate {
    public var delegate: GroupsTableVMDelegate?
    
    var reader: NewsReader = NewsReader(serverAddress: "news.easynews.com", port: 443, username: "nova1138", password: "Q@qwestar72Poi")
    
    init() {
        groups.append(contentsOf: reader.getGroups().map(NewsGroupVM.init))
        reader.delegate = self
    }
    
    func connected() {
        self.reader.list()
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
        groups.append(contentsOf: newGroups.map(NewsGroupVM.init))
        delegate?.groupsAdded()
    }
    
    var groups: [NewsGroupVM] = []
    
    public func getGroups() {
        reader.open()
    }
}
