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
    
    init(group: NewsGroupVM, groupsTableDelegate: GroupsTableDelegate?, frame: CGRect) {
        self.groupVM = group
        self.groupsTableDelegate = groupsTableDelegate
        super.init(frame: frame)
        loadViewFromNib()
        self.articlesTable.setViewModel(vm: ArticlesTableVM(group: group))
        //self.wantsLayer = true
        //self.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        //self.wantsLayer = true
        //self.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
}
