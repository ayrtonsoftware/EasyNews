//
//  GroupView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/3/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

class GroupTabView: NSView, LoadableNib, ListGroupArticlesDelegate {
    func ListGroupArticles_articlesAdded(newArticles: [String]) {
        //        groupsTableDelegate?.groupUpdated(group: groupVM)
        //        groupsTableDelegate?.reload()
    }
    
    func ListGroupsArticles_done(status: String) {
        //        groupsTableDelegate?.groupUpdated(group: groupVM)
        //        groupsTableDelegate?.reload()
    }
    
    func ListGroupsArticles_reload(vm: NewsGroupVM) {
        //p groupsTableDelegate?.groupUpdated(group: vm)
        //p groupsTableDelegate?.reload()
    }
    
    @IBAction func onGrouper(sender: NSButton) {
        if let vm = articlesVM {
            var grouped: [String: [NewsGroupArticleVM]] = [:]
            let regex = try! NSRegularExpression(pattern: "\\(\\d+\\/\\d+\\)|\\[\\d+\\/\\d+\\]")
            print("-------------------------------------------")
            vm.group.articles.forEach { (article: NewsGroupArticleVM) in
                let range = NSRange(location: 0, length: article.subject.utf16.count)
                let matches = regex.matches(in: article.subject, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: range)
                if matches.count > 0 {
                    let nsString = NSString(string: article.subject)
                    for match in matches {
                        // what will be the code
                        let range = match.range
                        let matchString = nsString.substring(with: match.range) as String
                        print("---------------------------------------------------------------------------------------->")
                        print("-------------------------------------------------->\(article.subject)<-------------------")
                        print("-------------------------------------------------> match is \(range) \(matchString)")
                        let subjectMinusIndex = article.subject.replacingOccurrences(of: matchString, with: "").trimmingCharacters(in: .whitespaces)
                        if grouped.keys.contains(subjectMinusIndex) {
                            var listOf = grouped.removeValue(forKey: subjectMinusIndex)
                            listOf?.append(article)
                            grouped[subjectMinusIndex] = listOf
                        } else {
                            grouped[subjectMinusIndex] = [article]
                        }
                        print("---------------------------------------------------------------------------------------->")
                    }
                    print("***")
                }
                else {
                    print(article.subject)
                }
            }
            print("-------------------------------------------")
        }
    }
    
    @objc private func onArticlesUpdated(_ notification: Notification) {
        if let articleIds = notification.object as? [String] {
            if let vm = articlesVM {
                print("yea")
                print(articleIds)
                _ = ArticleHeaderCommand(groupVM: vm.group,
                                         articleIds: articleIds,
                                         rbox: MainVC.getReaderBox(),
                                         reader: MainVC.CreateNewsReader())
            }
        }
    }
    
    @objc private func onArticleAdded(_ notification: Notification) {
        if let article = notification.object as? NewsGroupArticle {
            print("subject: \(article.subject)")
            if let vm = articlesVM {
                vm.group.articles = vm.group.articles.map { (existing: NewsGroupArticleVM) -> NewsGroupArticleVM in
                    if existing.id == article.id {
                        let mod = existing
                        mod.contentType = article.contentType ?? "N/A"
                        mod.subject = article.subject ?? "N/A"
                        return mod
                    }
                    return existing
                }
            }
        }
        articlesTable.reloadData()
        ////articlesTable.scrollToEndOfDocument(nil)
        articleCountLabel.stringValue = "\(groupVM?.articles.count ?? 0)"
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onArticlesUpdated(_:)),
                                               name: NotificationArticlesUpdated(groupName: groupVM?.name ?? "Unknown"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onArticleAdded(_:)),
                                               name: NotificationArticleAdded(groupName: groupVM?.name ?? "Unknown"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onArticleAdded(_:)),
                                               name: NotificationArticleUpdated(groupName: groupVM?.name ?? "Unknown"),
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
    
    @IBAction func onHeaders(sender: NSButton) {
        if let ids = groupVM?.articles.map({ (article: NewsGroupArticleVM) -> String in
            return article.id
        }),
            let groupVM = self.groupVM {
            _ = ArticleHeaderCommand(groupVM: groupVM,
                                     articleIds: ids,
                                     rbox: MainVC.getReaderBox(),
                                     reader: MainVC.CreateNewsReader())
        }
    }
    
    @IBAction func onRefresh(sender: NSButton) {
        if let groupVM = self.groupVM {
            _ = ListGroupArticlesCommand(groupVM: groupVM,
                                         rbox: MainVC.getReaderBox(),
                                         reader: MainVC.CreateNewsReader(),
                                         delegate: self)
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
        //self.wantsLayer = true
        //self.layer?.backgroundColor = NSColor.lightGray.cgColor
        addNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        articlesVM = nil
        super.init(coder: aDecoder)
        loadViewFromNib()
        //self.wantsLayer = true
        //self.layer?.backgroundColor = NSColor.lightGray.cgColor
        addNotifications()
    }
}
