//
//  GroupView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
import RealmSwift

class GroupTabView: NSView, LoadableNib {
    @objc private func onArticleGetHeader(_ notification: Notification) {
        if let articles = notification.object as? [ThreadSafeReference<NewsGroupArticle>] {
            print("onArticleGetHeader: \(Thread.threadName())")
            if let vm = articlesVM, let group = vm.group {
                _ = ArticleGetMultipleHeadersCommand(name: group.name,
                                                     groupId: group.id,
                                                     articleIds: articles.map({ (articleRef: ThreadSafeReference<NewsGroupArticle>) -> String in
                                                        let rbox = MainVC.getReaderBox()
                                                        if let realm = rbox.realm {
                                                            let article = realm.resolve(articleRef)
                                                            return article?.id ?? ""
                                                        }
                                                        return ""
                                                     }),
                                                     rbox: MainVC.getReaderBox(),
                                                     reader: MainVC.CreateNewsReader())
            }
        }
    }
    
    @objc private func onArticleAdd(_ notification: Notification) {
        if let articleVM = notification.object as? ArticleVM {
            articlesVM?.addArticle(article: articleVM)
        }
        DispatchQueue.main.sync {
            articlesTable.reloadData()
            articleCountLabel.stringValue = "\(articlesVM?.articles.count ?? 0)"
        }
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onArticleGetHeader(_:)),
                                               name: NotificationArticleGetHeader(groupName: group.name),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onArticleAdd(_:)),
                                               name: NotificationArticleHeaderAdded(groupName: group.name),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet var articleCountLabel: NSTextField!
    @IBOutlet var contentView: NSView!
    //@IBOutlet var articlesTable: ArticlesTableView!
    @IBOutlet var articlesTable: MeganTableView!

    private var group: NewsGroup
    private var groupsTableDelegate: GroupsTableDelegate?
    
    @IBAction func onRefresh(sender: NSButton) {
        _ = ListGroupGetArticleIdsCommand(name: group.name,
                                          group: group,
                                          rbox: MainVC.getReaderBox(),
                                          reader: MainVC.CreateNewsReader())
    }
    
    let articlesVM: ArticlesTableVM?
    
    init(group: NewsGroup, groupsTableDelegate: GroupsTableDelegate?, frame: CGRect) {
        self.group = group
        self.groupsTableDelegate = groupsTableDelegate
        //fixme
        articlesVM = ArticlesTableVM(group: group)
        //articlesVM = nil
        super.init(frame: frame)
        loadViewFromNib()
        articlesTable.setGroup(group: group)
        addNotifications()

//        if let vm = articlesVM {
//            self.articlesTable.setViewModel(vm: vm)
//        }
//        group.articles.forEach { (article: ArticleVM) in
//            articlesVM?.addArticle(article: article)
//        }
//        addNotifications()
//        self.articlesTable.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        articlesVM = nil
        self.group = NewsGroup()
        super.init(coder: aDecoder)
        loadViewFromNib()
        addNotifications()
    }
}
