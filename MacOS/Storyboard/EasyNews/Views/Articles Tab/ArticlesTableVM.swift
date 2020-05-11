//
//  ArticlesTableVM.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/4/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

class ArticleOutlineVM {
    var cache: [String: ArticleVM]
    var article: ArticleVM
    var children: [ArticleVM]
    
    init(article: ArticleVM) {
        self.article = article
        self.children = [article]
        self.cache = [:]
    }
}

class ArticlesTableVM {
    var group: NewsGroup
    var articleCache: [String: ArticleOutlineVM] = [:]
    var displayedCache: [String: String] = [:]
    var articles: [ArticleOutlineVM] = []
    //let regex = try! NSRegularExpression(pattern: "\\(\\d+\\/\\d+\\)|\\[\\d+\\/\\d+\\]")
    let regex = try! NSRegularExpression(pattern: "\\(\\d+\\/\\d+\\)")

    func updateArticle(article: ArticleVM) {
    }
    
    func addArticle(article: ArticleVM) {
        if let cArticle = articleCache[article.id] {
            cArticle.article.contentType = article.contentType
            cArticle.article.subject = article.subject
            if displayedCache[article.id] != nil {
                return
            }
        }
        
        if article.subject == "" {
            let vm = ArticleOutlineVM(article: article)
            articleCache[article.id] = vm
            return
        }
        
        displayedCache[article.id] = article.id
        
        let range = NSRange(location: 0, length: article.subject.utf16.count)
        let matches = regex.matches(in: article.subject, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: range)
        if matches.count == 1 {
            let nsString = NSString(string: article.subject)
            if let match = matches.first {
                let matchString = nsString.substring(with: match.range) as String
                let subjectMinusIndex = article.subject.replacingOccurrences(of: matchString, with: "").trimmingCharacters(in: .whitespaces)
                if articleCache.keys.contains(subjectMinusIndex) {
                    let multiArticle = articleCache[subjectMinusIndex]
                    multiArticle?.children.append(article)
                    
                    multiArticle?.children.sort(by: { (a: ArticleVM, b: ArticleVM) -> Bool in
                        return a.subject.fileNumber() < b.subject.fileNumber()
                    })
                } else {
                    let vm = ArticleOutlineVM(article: article)
                    articleCache[article.id] = vm
                    articles.append(vm)
                    articleCache[subjectMinusIndex] = vm
                }
            }
        } else {
            let vm = ArticleOutlineVM(article: article)
            articleCache[article.id] = vm
            articles.append(vm)
        }
    }
    
    init(group: NewsGroup) {
        self.group = group
        self.articles = []
    }
}
