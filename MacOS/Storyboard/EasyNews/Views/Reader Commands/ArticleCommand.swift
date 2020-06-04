//
//  ArticleCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/7/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation
import RealmSwift

protocol ArticleCommandDelegate: class {
    func onNewArticle(article: String)
}

class ArticleCommand: NewsReaderDelegate {
    var reader: NewsReader
    private weak var delegate: ArticleCommandDelegate?
    private var groupId: String
    private var articleId: String
    
    init(delegate: ArticleCommandDelegate?, name: String, group: NewsGroup, articleId: String, reader: NewsReader) {
        self.delegate = delegate
        self.groupId = group.id
        self.articleId = articleId
        self.reader = reader
        self.reader.delegate = self
        reader.open(name: "GetArticle_\(name)_\(articleId)")
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" {
            let rbox = MainVC.getReaderBox()
            
            if let group = rbox.findGroup(byId: self.groupId) {
                self.reader.article(groupName: group.name, articleId: articleId)
            }
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
    }
    
    func NewsReader_articleHeader(articleId: String, header: [String: String]) {
    }
    
    func NewsReader_article(article: String) {
        delegate?.onNewArticle(article: article)
    }
}
