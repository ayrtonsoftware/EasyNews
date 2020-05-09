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

    public func open(args : [String]) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = args
        task.currentDirectoryPath = "/Users/mbergamo/Data/Projects/me/current/EasyNews/tools/yenc-master"
        task.launch()
        task.waitUntilExit()
        let status = task.terminationStatus
        return (status)
    }

    public func uudecode(args : [String], encodedFile: String) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/uudecode"
        task.arguments = args
        task.currentDirectoryPath = "/Users/mbergamo/Data/Projects/me/current/EasyNews/tools/yenc-master"
        let inputpipe = Pipe()
        task.standardInput = inputpipe
        task.launch()
        if let data = encodedFile.data(using: .utf8) {
            inputpipe.fileHandleForWriting.write(data)
        }
        task.waitUntilExit()
        let status = task.terminationStatus
        return (status)
    }
    
    func onNewArticle(article: String) {
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                
                var lines: [String] = article.split(separator: "\r\n").map(String.init)
                
                var beginFound = false
                var endFound = false
                var isImage = false
                var filename = ""
                
                lines.forEach { (line: String) in
                    if line.starts(with: "begin ") {
                        beginFound = true
                        if line.contains(".jpg") || line.contains(".gif") {
                            // begin 600 HDV-HD-0089_050.jpg
                            let parts = line.split(separator: " ").map(String.init)
                            if parts.count == 3 {
                                isImage = true
                                filename = parts[2]
                            }
                        }
                    }
                    if line.starts(with: "end") {
                        endFound = true
                    }
                }
                
                if (beginFound && endFound) {
                    print("goooo")
                    if isImage {
                        let status = self.uudecode(args: [], encodedFile: article)
                        print("Status: \(status)")
                        if (status == 0) {
                            self.open(args: [filename])
                        }
                    }
                }
                
                
                
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
