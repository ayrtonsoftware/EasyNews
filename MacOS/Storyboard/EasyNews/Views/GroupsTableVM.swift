//
//  GroupTableVM.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation


class GroupsTableVM: NewsReaderDelegate {
    var reader: NewsReader = NewsReader(serverAddress: "news.easynews.com", port: 443, username: "nova1138", password: "Q@qwestar72Poi")
    
    init() {
        groups.append(contentsOf: reader.getGroups().map(NewsGroupVM.init))
    }
    
    func connected() {
    }
    
    func connectionFailed() {
    }
    
    func disconnected() {
    }
    
    func error(message: String) {
    }
    
    func groups(newGroups: [NewsGroup]) {
        groups.append(contentsOf: newGroups.map(NewsGroupVM.init))
    }
    
    var groups: [NewsGroupVM] = []
}
