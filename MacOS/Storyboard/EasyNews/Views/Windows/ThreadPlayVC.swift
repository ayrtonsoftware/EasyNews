//
//  ThreadPlayVC.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/9/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
import RealmSwift

class ThreadPlayVC: NSViewController {
    let producerQueue = DispatchQueue(label: "producer", attributes: .concurrent)
    
    var groupRefs: [ThreadSafeReference<NewsGroup>] = []
    
    @IBAction func onProducerStart(sender: NSButton) {
        producerQueue.async { [weak self] in
            autoreleasepool {
                if let self = self {
                    
                    let rbox = MainVC.getReaderBox()
                    if let realm = rbox.realm {
                        var unsafeGroups: [NewsGroup] = []
                        realm.beginWrite()
                        for idx in 1...1000 {
                            let newGroup: NewsGroup = NewsGroup()
                            realm.add(newGroup)
                            newGroup.name = "Group#\(idx)"
                            unsafeGroups.append(newGroup)
                        }
                        try! realm.commitWrite()
                        
                        unsafeGroups.forEach { (group: NewsGroup) in
                            let ref = ThreadSafeReference(to: group)
                            self.groupRefs.append(ref)
                        }
                        for idx in 1...60 {
                            realm.beginWrite()
                            unsafeGroups[0].name = "Update:\(idx)"
                            //print("Producer: Updated \(unsafeGroups[0].name ?? "")")
                            try! realm.commitWrite()
                            Thread.sleep(forTimeInterval: 1)
                            //realm.refresh()
                        }
                        
                    }
                }
            }
        }
    }
    
    let consumerQueue = DispatchQueue(label: "consumer", attributes: .concurrent)
    
    @IBAction func onConsumerStart(sender: NSButton) {
        DispatchQueue.init(label: "Consumer").async {
            autoreleasepool {
                let rbox = MainVC.getReaderBox()
                if let realm = rbox.realm {
                    var groups: [NewsGroup] = []
                    self.groupRefs.forEach { (groupRef: ThreadSafeReference<NewsGroup>) in
                        if let group = realm.resolve(groupRef) {
                            groups.append(group)
                        }
                    }
                    realm.beginWrite()
                    groups.forEach { (group: NewsGroup) in
                        group.name = "Changed\(group.name ?? "NoName")"
                        //print("Group: \(group.name ?? "NoName")")
                    }
                    try! realm.commitWrite()
                    
                    for idx in 1...60 {
                        //print("Consumer: \(groups[0].name ?? "")")
                        Thread.sleep(forTimeInterval: 1)
                        realm.refresh()
                    }
                    //print("Done")
                }
            }
        }
    }
}
