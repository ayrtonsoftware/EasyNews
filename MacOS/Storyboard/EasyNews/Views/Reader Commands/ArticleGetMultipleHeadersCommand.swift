//
//  ArticleHeadCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation
import RealmSwift

class ArticleGetMultipleHeadersCommand: NewsReaderDelegate {
    var reader: NewsReader
    private var rbox: ReaderBox
    private var articleIds: [String]
    private var groupId: String
    private var idx = 0
    
    init(name: String, groupId: String, articleIds: [String], rbox: ReaderBox, reader: NewsReader) {
        self.articleIds = articleIds
        self.rbox = rbox
        self.groupId = groupId
        self.reader = reader
        self.reader.delegate = self
        reader.open(name: "GetArticleHeader_\(name)_\(articleIds.count)")
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" || notification == "NextArticle" {
            if let group = rbox.findGroup(byId: self.groupId) {
                if idx < articleIds.count {
                    self.reader.articleHeader(groupName: group.name, articleId: articleIds[idx])
                    idx += 1
                } else {
                    reader.close()
                }
            }
        }
        if notification == "Done" {
            //print("Done getting list")
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
        //DispatchQueue.main.sync {
//            header.keys.forEach { (key: String) in
//                if key.uppercased().contains("Date") {
//                    print("--Date--> \(header[key])----")
//                }
//            }
            if let group = rbox.findGroup(byId: self.groupId) {
                rbox.realm?.beginWrite()
                let (article, isNewArticle) = rbox.findOrCreateGroupArticle(group: group, articleId: articleId)
                article.subject = header["Subject"]
                article.contentType = header["Content-Type"]
                if let bytes = header["Bytes"] {
                    article.size.value = Int(bytes) ?? 0
                }
                // Thu, 30 May 2019 17:37:53 +0100
                // NNTP-Posting-Date
                if let dateStr = header["Date"] {
                    if let date = Date.parse(string: dateStr) {
                        article.date = date
                    } else {
                        print("---bad date [\(dateStr)]")
                    }
                }
                
                if let bytes = header["X-Received-Bytes"] {
                    article.size.value = Int(bytes) ?? 0
                }
                
                // fix me
//                let groups = header["Newsgroups"]?.split(separator: ",").map(String.init)
//                groups?.forEach({ (groupName: String) in
//                    if let referencedGroup = rbox.findGroup(name: groupName) {
//                        referencedGroup.articles.append(article)
//                    }
//                })
                
                do {
                    try rbox.realm?.commitWrite()
                }
                catch {
                    print("article update error: \(error)")
                }
                NotificationCenter.default.post(name: NotificationArticleHeaderAdded(groupName: group.name),
                                                object: ArticleVM(article: article))
            }
        //}
    }
    
    func NewsReader_article(article: String) {
    }
}
