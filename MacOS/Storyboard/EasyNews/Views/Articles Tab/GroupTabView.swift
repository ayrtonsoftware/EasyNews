//
//  GroupView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

class GroupTabView: NSView, LoadableNib {
    @objc private func onArticleGetHeader(_ notification: Notification) {
        if let articles = notification.object as? [ArticleVM] {
            if let vm = articlesVM {
                _ = ArticleHeaderCommand(groupVM: vm.group,
                                         articleIds: articles.map({ (article: ArticleVM) -> String in
                                            article.id
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
        articlesTable.reloadData()
        articleCountLabel.stringValue = "\(articlesVM?.articles.count ?? 0)"
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onArticleGetHeader(_:)),
                                               name: NotificationArticleGetHeader(groupName: groupVM?.name ?? "Unknown"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onArticleAdd(_:)),
                                               name: NotificationArticleHeaderAdded(groupName: groupVM?.name ?? "Unknown"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet var articleCountLabel: NSTextField!
    @IBOutlet var contentView: NSView!
    @IBOutlet var articlesTable: ArticlesTableView!
    
    private var groupVM: NewsGroupVM?
    private var groupsTableDelegate: GroupsTableDelegate?
    
    @IBAction func onRefresh(sender: NSButton) {
        if let groupVM = self.groupVM {
            _ = ListGroupGetArticleIdsCommand(groupVM: groupVM,
                                              rbox: MainVC.getReaderBox(),
                                              reader: MainVC.CreateNewsReader())
        }
    }
    
    let articlesVM: ArticlesTableVM?
    
    init(group: NewsGroupVM, groupsTableDelegate: GroupsTableDelegate?, frame: CGRect) {
        self.groupVM = group
        self.groupsTableDelegate = groupsTableDelegate
        articlesVM = ArticlesTableVM(group: group)
        super.init(frame: frame)
        loadViewFromNib()
        if let vm = articlesVM {
            self.articlesTable.setViewModel(vm: vm)
        }
        group.articles.forEach { (article: ArticleVM) in
            articlesVM?.addArticle(article: article)
        }
        addNotifications()
        self.articlesTable.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        articlesVM = nil
        super.init(coder: aDecoder)
        loadViewFromNib()
        addNotifications()
    }
}
