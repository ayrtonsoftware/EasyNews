//
//  ListGroupArticlesCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

class ListGroupGetArticleIdsCommand: NewsReaderDelegate {
    var reader: NewsReader
    private var rbox: ReaderBox
    private var groupVM: NewsGroupVM
    
    init(groupVM: NewsGroupVM, rbox: ReaderBox, reader: NewsReader) {
        self.groupVM = groupVM
        self.rbox = rbox
        self.reader = reader
        self.reader.delegate = self
        reader.open(name: "GetArticleIds_\(groupVM.name)")
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" {
            self.reader.listArticles(groupName: self.groupVM.name)
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
    
    func NewsReader_groups(groups: [Group]) {
    }
    
    func NewsReader_articles(articleIds: [String]) {
        DispatchQueue.main.sync { [weak self] in
            if let self = self {
                self.rbox.realm?.beginWrite()
                var newArticles: [ArticleVM] = []
                
                if let group = self.groupVM.group {
                    articleIds.forEach { (articleId: String) in
                        let (article, isNewArticle) = self.rbox.findOrCreateGroupArticle(group: group, articleId: articleId)
                        if isNewArticle {
                            newArticles.append(ArticleVM(article: article))
                            groupVM.articles.append(ArticleVM(article: article))
                        }
                    }
                    
                    //if newArticles.count > 0 {
                        NotificationCenter.default.post(name: NotificationGroupUpdated(), object: group)
                        NotificationCenter.default.post(name: NotificationArticleGetHeader(groupName: group.name), object: newArticles)
                    //}
                }
                
                do {
                    try self.rbox.realm?.commitWrite()
                }
                catch {
                    print("Realm error \(error)")
                }
            }
        }
    }
    
    func NewsReader_articleHeader(articleId: String, header: [String: String]) {
    }
    
    func NewsReader_article(article: String) {
    }
}
