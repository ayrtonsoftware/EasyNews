//
//  ListGroupsCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation
//
//protocol ListGroupsDelegate: class {
//    func ListGroups_groupsAdded(newGroups: [NewsGroup])
//    func ListGroups_done(status: String)
//    func ListGroups_refresh()
//}

class ListGroupsCommand: NewsReaderDelegate {
    var reader: NewsReader
    //var delegate: ListGroupsDelegate?
    private var rbox: ReaderBox
    
    init(rbox: ReaderBox, reader: NewsReader/*, delegate: ListGroupsDelegate*/) {
        self.rbox = rbox
        self.reader = reader
        self.reader.delegate = self
        //self.delegate = delegate
        reader.open(name: "ListGroups")
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" {
            print("List Groups")
            self.reader.listGroups()
            return
        }
        
        if notification == "Done" {
            print("Done getting list")
            reader.close()
        }
        if notification == "ConnectionFailed" {
            print("Connection failed")
        }
        
        if notification == "Disconnected" {
            print("Connection disconnected")
        }
    }
    
    func NewsReader_error(message: String) {
        print("New Reader Error: \(message)")
    }
    
    func NewsReader_groups(groups: [Group]) {
        DispatchQueue.main.sync { [weak self] in
            rbox.realm?.beginWrite()
            var newGroups: [NewsGroup] = []
            
            groups.forEach { (group: Group) in
                let (newGroup, isNewGroup) = rbox.findOrCreateGroup(name:group.name, first: group.first, last: group.last, canPost: group.canPost)
                newGroup.updated = Date()
                newGroups.append(newGroup)
            }

            NotificationCenter.default.post(name: NotificationGroupAdded(), object: newGroups)

            do {
                try rbox.realm?.commitWrite()
            }
            catch {
                print("Realm error \(error)")
            }
        }
    }
    
    func NewsReader_articles(articleIds: [String]) {
    }
    
    func NewsReader_articleHeader(articleId: String, header: [String: String]) {        
    }
    
    func NewsReader_article(article: String) {        
    }
}
