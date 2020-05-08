//
//  ArticlesTableView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/4/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa

class ArticlesTableView: NSOutlineView, NSOutlineViewDataSource, NSOutlineViewDelegate, ArticleCommandDelegate {
    func GroupsTable_reload() {
        reloadData()
    }
    
    var vm: ArticlesTableVM?
    
    public func setViewModel(vm: ArticlesTableVM) {
        self.vm = vm
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.dataSource = self
        self.delegate = self
    }
    
    func formatOutput(output: String) -> NSMutableAttributedString {
        let font = NSFont(name: "Courier", size: 14)
        let attributedText = NSMutableAttributedString(string: output,
                                                       attributes: [NSAttributedString.Key.font: font])
        return attributedText
    }
    
    @IBOutlet var articleView: NSTextView!
    
    func onNewArticle(article: String) {
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                self.articleView.string = ""
                self.articleView.textStorage?.append(self.formatOutput(output: article))
            }
//            if let self = self {
//                let storyboard = NSStoryboard(name: "ArticleWindow", bundle: nil)
//                if let window = storyboard.instantiateController(withIdentifier: "Article") as? NSWindowController {
//                    if let vc = window.contentViewController as? ArticleWindowVC {
//                        vc.text.textStorage?.append(self.formatOutput(output: article))
//                    }
//                    window.showWindow(window)
//                }
//            }
        }
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let vm = self.vm else {
            return
        }
                    
        var what = self.item(atRow: selectedRow)
        print(what)
        if let a = what as? ArticleVM {
            print("get data for article \(a.id)")
            ArticleCommand(delegate: self, groupVM: vm.group, articleId: a.id, reader: MainVC.CreateNewsReader())
        }
        if let a = what as? ArticleOutlineVM {
            print("ArticleOutlineVM")
            if a.children.count == 1 {
                print("get data for article \(a.article.id)")
                ArticleCommand(delegate: self, groupVM: vm.group, articleId: a.article.id, reader: MainVC.CreateNewsReader())
            }
            if a.children.count > 1 {
                print("-----------------------------------")
                a.children.forEach { (article: ArticleVM) in
                    print("get article for \(article.id)")
                }
                print("-----------------------------------")
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return vm?.articles.count ?? 0
        }
        if let item = item as? ArticleOutlineVM {
            return item.children.count
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return vm?.articles[index]
        }
        if let item = item as? ArticleOutlineVM {
            return item.children[index]
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? ArticleOutlineVM {
            return item.children.count > 1
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let article = item as? ArticleVM {
            if tableColumn?.identifier.rawValue == "id" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.id
                return cell
            }
            if tableColumn?.identifier.rawValue == "subject" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.subject
                return cell
            }
            if tableColumn?.identifier.rawValue == "contentType" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.contentType
                return cell
            }
            if tableColumn?.identifier.rawValue == "size" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = "\(article.size) \(article.size.formatFileSize())"
                return cell
            }
            if tableColumn?.identifier.rawValue == "date" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                if let date = article.date {
                    cell?.textField?.stringValue = date.toString(format: "MM/dd/yyyy hh:mm a")
                } else {
                    cell?.textField?.stringValue = "N/A"
                }
                return cell
            }
        }
        if let item2 = item as? ArticleOutlineVM {
            let article = item2.article
            
            if tableColumn?.identifier.rawValue == "id" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.id
                return cell
            }
            if tableColumn?.identifier.rawValue == "subject" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.subject.nudeSubject()
                return cell
            }
            if tableColumn?.identifier.rawValue == "contentType" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = article.contentType
                return cell
            }
            if tableColumn?.identifier.rawValue == "size" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = "\(article.size) \(article.size.formatFileSize())"
                return cell
            }
            if tableColumn?.identifier.rawValue == "date" {
                let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
                if let date = article.date {
                    cell?.textField?.stringValue = date.toString(format: "MM/dd/yyyy hh:mm a")
                } else {
                    cell?.textField?.stringValue = "N/A"
                }
                return cell
            }
        }
        if item == nil {
            return nil
        }
        return nil
    }
}
