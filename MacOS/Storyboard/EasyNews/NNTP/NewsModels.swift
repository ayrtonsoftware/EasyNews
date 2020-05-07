//
//  NewsGroup.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/2/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation
import RealmSwift

class NewsGroup: Object
{
    @objc dynamic var name: String!
    @objc dynamic var updated: Date!
    let first = RealmOptional<Int>()
    let last = RealmOptional<Int>()
    let canPost = RealmOptional<Bool>()
    let articles = List<NewsGroupArticle>()
}

class NewsGroupArticle: Object {
    @objc dynamic var group: NewsGroup?
    @objc dynamic var id: String?
    @objc dynamic var subject: String?
    @objc dynamic var contentType: String?
    @objc dynamic var date: Date!
    let size = RealmOptional<Int>()
}
