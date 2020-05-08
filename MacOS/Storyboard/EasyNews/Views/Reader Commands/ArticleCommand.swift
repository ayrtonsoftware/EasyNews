//
//  ArticleCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/7/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

protocol ArticleCommandDelegate: class {
    func onNewArticle(article: String)
}

class ArticleCommand: NewsReaderDelegate {
    var reader: NewsReader
    private weak var delegate: ArticleCommandDelegate?
    private var groupVM: NewsGroupVM
    private var articleId: String
    
    init(delegate: ArticleCommandDelegate?, groupVM: NewsGroupVM, articleId: String, reader: NewsReader) {
        self.delegate = delegate
        self.groupVM = groupVM
        self.articleId = articleId
        self.reader = reader
        self.reader.delegate = self
        reader.open()
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" {
            self.reader.article(groupName: groupVM.name, articleId: articleId)
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
    }
    
    func NewsReader_articleHeader(articleId: String, header: [String: String]) {
    }
    
    func NewsReader_article(article: String) {
        delegate?.onNewArticle(article: article)
    }
}
