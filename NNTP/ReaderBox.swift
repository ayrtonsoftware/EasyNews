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
        if let cachedRealm = ReaderBox.realms[Thread.threadName()] {
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
                schemaVersion: 1,
                
                migrationBlock: { migration, oldSchemaVersion in
                    
                    print("Version \(oldSchemaVersion)")
            })
            //RLMRealmConfiguration.setDefault(config)
            Realm.Configuration.defaultConfiguration = config
            let realm = try Realm()
            if let url = config.fileURL {
                print("\n\n\nRealm Path: \(url.absoluteString)\n\n\n")
            }
            ReaderBox.realms[Thread.threadName()] = realm
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

    func findOrCreateGroup(name: String, first: Int, last: Int, canPost: Bool) -> NewsGroup? {
        var theGroup: NewsGroup?
        
        if let group = findGroup(withFilter: "name='\(name)'") {
            theGroup = group
            group.first.value = first
            group.last.value = last
            group.canPost.value = canPost
        } else {
            let newGroup = NewsGroup()
            theGroup = newGroup
            newGroup.name = name
            newGroup.first.value = first
            newGroup.last.value = last
            newGroup.canPost.value = canPost
            realm?.add(newGroup)
        }
        return theGroup
    }
}
