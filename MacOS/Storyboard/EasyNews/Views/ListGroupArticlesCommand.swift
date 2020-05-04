//
//  ListGroupArticlesCommand.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

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
    
    func connected() {
        self.reader.listArticles(groupName: self.groupVM.name)
    }
    
    func done() {
        print("Done getting list")
        reader.close()
        delegate?.ListGroupsArticles_reload(vm: groupVM)
    }
    
    func connectionFailed() {
    }
    
    func disconnected() {
    }
    
    func error(message: String) {
    }
    
    func groups(groups: [Group]) {
    }
    
    func articles(articles: [String]) {
        rbox.realm?.beginWrite()
        
        articles.forEach { (article: String) in
            if let group = groupVM.group {
                let article = rbox.findOrCreateGroupAticle(group: group, articleId: article)
                self.groupVM.articles.append(NewsGroupArticleVM(article: article))
            }
        }
        
        do {
            try rbox.realm?.commitWrite()
        }
        catch {
            print("Realm error \(error)")
        }
    }
}
