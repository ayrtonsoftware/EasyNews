//
//  ListGroupArticlesCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

protocol ListGroupArticlesDelegate: class {
    func ListGroupArticles_articlesAdded(newArticles: [String])
    func ListGroupsArticles_done(status: String)
    func ListGroupsArticles_reload(vm: NewsGroupVM)
}

class ListGroupArticlesCommand: NewsReaderDelegate {
    var reader: NewsReader
    var delegate: ListGroupArticlesDelegate?
    private var rbox: ReaderBox
    private var groupVM: NewsGroupVM
    
    init(groupVM: NewsGroupVM, rbox: ReaderBox, reader: NewsReader, delegate: ListGroupArticlesDelegate?) {
        self.groupVM = groupVM
        self.rbox = rbox
        self.reader = reader
        self.reader.delegate = self
        self.delegate = delegate
        reader.open()
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
            delegate?.ListGroupsArticles_reload(vm: groupVM)
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
    
    func NewsReader_articles(articles: [String]) {
        DispatchQueue.main.sync { [weak self] in
            if let self = self {
                self.rbox.realm?.beginWrite()
                
                if let group = self.groupVM.group {
                    articles.forEach { (article: String) in
                        let (article, isNewArticle) = self.rbox.findOrCreateGroupArticle(group: group, articleId: article)
                        self.groupVM.articles.append(NewsGroupArticleVM(article: article))
                        NotificationCenter.default.post(name: (isNewArticle) ? NotificationArticleAdded(groupName: group.name) : NotificationArticleUpdated(groupName: group.name),
                                                        object: article)
                        NotificationCenter.default.post(name: NotificationGroupUpdated(), object: group)
                    }
                    
                    NotificationCenter.default.post(name: NotificationArticlesUpdated(groupName: group.name),
                                                    object: articles)
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
}
