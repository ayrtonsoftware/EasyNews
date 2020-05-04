//
//  ListGroupsCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

protocol ListGroupsDelegate: class {
    func ListGroups_groupsAdded(newGroups: [NewsGroup])
    func ListGroups_done(status: String)
    func ListGroups_refresh()
}

class ListGroupsCommand: NewsReaderDelegate {
    var reader: NewsReader
    var delegate: ListGroupsDelegate?
    private var rbox: ReaderBox
    
    init(rbox: ReaderBox, reader: NewsReader, delegate: ListGroupsDelegate) {
        self.rbox = rbox
        self.reader = reader
        self.reader.delegate = self
        self.delegate = delegate
        reader.open()
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" {
            self.reader.listGroups()
            return
        }
        if notification == "Done" {
            print("Done getting list")
            reader.close()
            delegate?.ListGroups_done(status: "Done")
        }
        if notification == "ConnectionFailed" {
            delegate?.ListGroups_done(status: "ConnectionFailed")
        }
        if notification == "Disconnected" {
            delegate?.ListGroups_done(status: "Disconnected")
        }
    }
    
    func NewsReader_error(message: String) {
        delegate?.ListGroups_done(status: message)
    }
    
    func NewsReader_groups(groups: [Group]) {
        rbox.realm?.beginWrite()
        var newGroups: [NewsGroup] = []
        
        groups.forEach { (group: Group) in
            if let newGroup = rbox.findOrCreateGroup(name:group.name, first: group.first, last: group.last, canPost: group.canPost) {
                newGroup.updated = Date()
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
    
    func NewsReader_articles(articles: [String]) {        
    }
    
    func NewsReader_articleHeader(articleId: String, header: [String: String]) {        
    }
}
