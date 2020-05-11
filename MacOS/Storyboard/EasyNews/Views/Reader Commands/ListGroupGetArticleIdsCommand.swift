//
//  ListGroupArticlesCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
import RealmSwift

class ListGroupGetArticleIdsCommand: NewsReaderDelegate {
    var reader: NewsReader
    private var rbox: ReaderBox
    private var groupRef: ThreadSafeReference<NewsGroup>
    private var group: NewsGroup?
    
    init(name: String, groupRef: ThreadSafeReference<NewsGroup>, rbox: ReaderBox, reader: NewsReader) {
        self.groupRef = groupRef
        self.rbox = rbox
        self.reader = reader
        self.reader.delegate = self
        reader.open(name: "GetArticleIds_\(name)")
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" {
            if let realm = rbox.realm, let group = realm.resolve(groupRef) {
                self.group = group
                self.reader.listArticles(groupName: group.name)
            } else {
                reader.close()
            }
            return
        }
        if notification == "Done" {
            print("Done getting list")
            reader.close()
        }
        if notification == "ConnectionFailed" {
        }
        if notification == "Disconnected" {
        }
    }
    
    func NewsReader_error(message: String) {
    }
    
    func NewsReader_groups(groups: [NewsGroup]) {
    }
    
    func NewsReader_articles(articleIds: [String]) {
        if let realm = rbox.realm {
            
            var newArticles: [NewsGroupArticle] = []
            
            if let group = self.group {
                realm.beginWrite()
                articleIds.forEach { (articleId: String) in
                    let (article, isNewArticle) = self.rbox.findOrCreateGroupArticle(group: group, articleId: articleId)
                    if isNewArticle {
                        newArticles.append(article)
                        group.articles.append(article)
                    }
                }
                do {
                    try self.rbox.realm?.commitWrite()
                }
                catch {
                    print("Realm error \(error)")
                }
                realm.refresh()
                
                var articleRefs: [ThreadSafeReference<NewsGroupArticle>] = []
                newArticles.forEach { (article: NewsGroupArticle) in
                    let articleRef = ThreadSafeReference(to: article)
                    articleRefs.append(articleRef)
                }
                //if newArticles.count > 0 {
                NotificationCenter.default.post(name: NotificationGroupUpdated(), object: group)
                NotificationCenter.default.post(name: NotificationArticleGetHeader(groupName: group.name), object: articleRefs)
                //}
            }
        }
    }
    
    func NewsReader_articleHeader(articleId: String, header: [String: String]) {
    }
    
    func NewsReader_article(article: String) {
    }
}
