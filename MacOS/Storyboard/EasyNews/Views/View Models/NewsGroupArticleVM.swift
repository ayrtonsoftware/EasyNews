//
//  NewsGroupArticleVM.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/7/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

class NewsGroupArticleVM {
    var id: String
    var subject: String
    var contentType: String
    var size: Int
    var date: Date?
    
    public init(article: NewsGroupArticle) {
        id = article.id ?? ""
        subject = article.subject ?? ""
        contentType = article.contentType ?? "N/A"
        size = article.size.value ?? 0
        date = article.date
    }
}
