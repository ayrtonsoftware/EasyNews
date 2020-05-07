//
//  ReaderBox.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/29/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation
import RealmSwift

extension Thread {
    public class func threadName() -> String {
        //return "\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r"
        return OperationQueue.current?.underlyingQueue?.label ?? "\(Thread.current)"
    }
}

class ReaderBox: NSObject {
    static var realms: [String: Realm?] = [:]
        
    var realm: Realm? {
        let threadName = Thread.threadName()
        if let cachedRealm = ReaderBox.realms[threadName] {
            //print("Getting realm from thread [\(threadName)]")
            return cachedRealm
        }
        
        var pathURL = URL(fileURLWithPath: NSHomeDirectory())
        pathURL = pathURL.appendingPathComponent("EasyNews")
        var fileURL = pathURL.appendingPathComponent("easynews.realm")
        do {
            if !FileManager.default.fileExists(atPath: pathURL.path) {
                try FileManager.default.createDirectory(at: pathURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: [:])
            }
            
            print("Realm Path: \(pathURL)\n\n\n")
            
            let config = Realm.Configuration(
                fileURL: fileURL,
                schemaVersion: 2,
                
                migrationBlock: { migration, oldSchemaVersion in
                    
                    print("Version \(oldSchemaVersion)")
            })
            //RLMRealmConfiguration.setDefault(config)
            Realm.Configuration.defaultConfiguration = config
            let realm = try Realm()
            if let url = config.fileURL {
                print("\n\n\nRealm Path: \(url.absoluteString)\n\n\n")
            }
            ReaderBox.realms[threadName] = realm
            
//            print("Adding new realm from thread [\(threadName)]")
//            ReaderBox.realms.keys.forEach { (key: String) in
//                print("Realms --> \(key)")
//            }
            
            return realm
        }
        catch {
            print(error)
        }
        return nil
    }
    
    func findGroup(withFilter: String) -> NewsGroup? {
        guard let realm = self.realm else {
            print("ReaderBox NOT OPENED")
            return nil
        }
        
        let cursor = realm.objects(NewsGroup.self).filter(withFilter)
        if cursor.count > 0 {
            return cursor.first
        }
        return nil
    }
    
    func findOrCreateGroupArticle(group: NewsGroup, articleId: String) -> (NewsGroupArticle, Bool) {
        if let article = group.articles.first(where: { (article: NewsGroupArticle) -> Bool in
            return article.id == articleId
        }) {
            return (article, false)
        }
    
        let newArticle = NewsGroupArticle()
        newArticle.group = group
        newArticle.id = articleId
        newArticle.subject = ""
        newArticle.contentType = ""
        group.articles.append(newArticle)
        realm?.add(newArticle)
        //NotificationCenter.default.post(name: Notification.Name(NotificationArticlesAdded(groupName: group.name)), object: newArticle)
        return (newArticle, true)
    }

    func findGroup(name: String) -> NewsGroup? {
        
        if let group = findGroup(withFilter: "name='\(name)'") {
            return group
        }
        return nil
    }

    func findOrCreateGroup(name: String, first: Int, last: Int, canPost: Bool) -> (NewsGroup, Bool) {
        
        if let group = findGroup(withFilter: "name='\(name)'") {
            return (group, false)
        }
        let newGroup = NewsGroup()
        newGroup.name = name
        newGroup.updated = Date()
        newGroup.first.value = first
        newGroup.last.value = last
        newGroup.canPost.value = canPost
        realm?.add(newGroup)
        //NotificationCenter.default.post(name: Notification.Name(NotificationGroupAdded()), object: newGroup)
        return (newGroup, true)
    }
}
