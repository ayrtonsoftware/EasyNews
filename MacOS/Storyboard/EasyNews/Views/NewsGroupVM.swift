//
//  NewsReaderModels.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/30/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

class NewsGroupArticleVM/*: Identifiable, Hashable*/ {
    var id: String
    var subject: String
    var contentType: String
    
    public init(article: NewsGroupArticle) {
        id = article.id ?? ""
        subject = article.subject ?? ""
        contentType = ""
        if let ct = article.contentType as? String? {
            contentType = ct ?? "N/A"
        }
    }
}

class NewsGroupVM /*: Identifiable, Hashable*/ {
    var group: NewsGroup?
    var id: String = UUID().uuidString
    var name: String
    var first: Int
    var last: Int
    var updated: Date
    var progress: Double = 0.0
    var articles: [NewsGroupArticleVM] = []
    
    public init(group: NewsGroup) {
        self.group = group
        self.name = group.name
        self.first = group.first.value ?? 0
        self.last = group.last.value ?? 0
        self.updated = group.updated
        self.articles = group.articles.map(NewsGroupArticleVM.init)
    }
    
    public init(name: String) {
        self.name = name
        self.first = 0
        self.last = 0
        self.progress = 0.0
        self.updated = Date()
        self.articles = []
    }
}
