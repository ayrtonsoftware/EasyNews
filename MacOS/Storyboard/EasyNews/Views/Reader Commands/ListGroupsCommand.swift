//
//  ListGroupsCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation
import RealmSwift

class ListGroupsCommand: NewsReaderDelegate {
    var reader: NewsReader
    
    init(reader: NewsReader/*, delegate: ListGroupsDelegate*/) {
        self.reader = reader
        self.reader.delegate = self
        reader.open(name: "ListGroups")
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" {
            //print("List Groups")
            self.reader.listGroups()
            return
        }
        
        if notification == "Done" {
            //print("Done getting list")
            reader.close()
        }
        if notification == "ConnectionFailed" {
            //print("Connection failed")
        }
        
        if notification == "Disconnected" {
            //print("Connection disconnected")
        }
    }
    
    func NewsReader_error(message: String) {
        //print("New Reader Error: \(message)")
    }
    
    func NewsReader_groups(groups: [NewsGroup]) {
        let rbox = MainVC.getReaderBox()
        
        rbox.realm?.beginWrite()
        var newGroups: [NewsGroup] = []
        groups.forEach { (group: NewsGroup) in
            let (newGroup, _ /* isNewGroup */) = rbox.findOrCreateGroup(name:group.name)
                                                                        //first: group.first.value ?? 0,
                                                                        //last: group.last.value ?? 0,
                                                                        //canPost: group.canPost.value ?? false)
            newGroup.first.value = group.first.value
            newGroup.last.value = group.last.value
            newGroup.canPost.value = group.canPost.value
            newGroup.updated = Date()
            newGroups.append(newGroup)
        }
        do {
            try rbox.realm?.commitWrite()
        }
        catch {
            //print("Realm error \(error)")
        }
        rbox.realm?.refresh()
        NotificationCenter.default.post(name: NotificationGroupsAdded(), object: nil)
    }
    
    func NewsReader_articles(articleIds: [String]) {
    }
    
    func NewsReader_articleHeader(articleId: String, header: [String: String]) {        
    }
    
    func NewsReader_article(article: String) {        
    }
}
