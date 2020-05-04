//
//  ArticleHeadCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

import Foundation

protocol ArticleHeaderDelegate: class {
    func ArticleHeader_done(status: String)
}

class ArticleHeaderCommand: NewsReaderDelegate {
    var reader: NewsReader
    private var rbox: ReaderBox
    private var articleIds: [String]
    private var groupVM: NewsGroupVM
    private var idx = 0
    
    init(groupVM: NewsGroupVM, articleIds: [String], rbox: ReaderBox, reader: NewsReader) {
        self.groupVM = groupVM
        self.articleIds = articleIds
        self.rbox = rbox
        self.reader = reader
        self.reader.delegate = self
        reader.open()
    }
    
    func NewsReader_notification(notification: String)
    {
        if notification == "Connected" || notification == "NextArticle" {
            if idx < articleIds.count {
                print("********************************** getting article \(idx)")
                self.reader.articleHeader(groupName: groupVM.name, articleId: articleIds[idx])            
                idx += 1
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
    
    func NewsReader_groups(groups: [Group]) {
    }
    
    func NewsReader_articles(articles: [String]) {
    }
    
    func NewsReader_articleHeader(articleId: String, header: [String: String]) {
        if let group = groupVM.group {
            rbox.realm?.beginWrite()
            var article = rbox.findOrCreateGroupAticle(group: group, articleId: articleId)
            article.subject = header["Subject"]
            article.contentType = header["Content-Type"]
            
            var groups = header["Newsgroups"]?.split(separator: ",").map(String.init)
            groups?.forEach({ (groupName: String) in
                if let referencedGroup = rbox.findGroup(name: groupName) {
                    referencedGroup.articles.append(article)
                }
            })
            
//            header.keys.forEach { (key: String) in
//                //print(">>>>>article \(articleId) - \(key)------\(header[key]!)-------")
//                if key == "Subject" {
//                    article.subject = header[key]
//                }
//                if key == "Content-Type" {
//                    article.contentType = header[key]
//                }
//                if key == "Newsgroups" {
//                    print(header[key])
//                    var groups = header[key]?.split(separator: ",").map(String.init)
//                    groups?.forEach({ (groupName: String) in
//                        if let referencedGroup = rbox.findGroup(name: groupName) {
//                            referencedGroup.articles.append(article)
//                        }
//                    })
//                }
//            }
            do {
                try rbox.realm?.commitWrite()
            }
            catch {
                print("article update error: \(error)")
            }
        }
    }
}