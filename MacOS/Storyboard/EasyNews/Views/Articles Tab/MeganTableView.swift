//
//  MeganTableView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/11/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Cocoa
import RealmSwift

class MeganTableView: NSOutlineView, NSOutlineViewDataSource, NSOutlineViewDelegate, ArticleCommandDelegate {
    private var group: NewsGroup?
    private var result: Results<NewsGroupArticle>?
    
    public func setGroup(group: NewsGroup) {
        self.group = group
        let rbox = MainVC.getReaderBox()
        if let realm = rbox.realm,
            let groupId = group.id {
//            realm.beginWrite()
//            var art = NewsGroupArticle()
//            art.group = group
//            art.subject = "This is a test"
//            art.size.value = 10000
//            realm.add(art)
//            group.articles.append(art)
//            try! realm.commitWrite()
            result = realm.objects(NewsGroupArticle.self).filter("group.id='\(groupId)'")
            reloadData()
        }
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
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if (item == nil) {
            return result?.count ?? 0
        }
        if let article = item as? NewsGroupArticle {
            return article.parts.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item == nil ){
            if let article: NewsGroupArticle? = result?[index] {
                //////print(article?.subject)
                return article
            }
        }
        
        if let article = item as? NewsGroupArticle {
            return article.parts[index]
        }
        return NewsGroupArticle()
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let article = item as? NewsGroupArticle {
            return article.parts.count > 1
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cell = makeView(withIdentifier: (tableColumn!.identifier),
                            owner: self) as? NSTableCellView

        var stringValue = "*"

        if tableColumn?.identifier.rawValue == "subject" {
            if let article = item as? NewsGroupArticle {
                stringValue = article.subject ?? "No Subject"
            } else {
                stringValue = "No Subject"
            }
        }

        if tableColumn?.identifier.rawValue == "id" {
            if let article = item as? NewsGroupArticle {
                stringValue = article.id ?? "*"
            } else {
                stringValue = "**"
            }
        }
        if tableColumn?.identifier.rawValue == "date" {
            if let article = item as? NewsGroupArticle {
                stringValue = article.date?.toString(format: "MM/dd/yyyy") ?? "***"
            } else {
                stringValue = "**"
            }
        }
        if tableColumn?.identifier.rawValue == "size" {
            if let article = item as? NewsGroupArticle {
                stringValue = article.size.value?.formatFileSize() ?? "*"
            } else {
                stringValue = "**"
            }
        }
        
        cell?.textField?.stringValue = stringValue
        return cell
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        if let group = self.group {
            var what = self.item(atRow: selectedRow)
            
            if let a = what as? NewsGroupArticle {
                ArticleCommand(delegate: self,
                               name: "Hello",
                               group: group,
                               articleId: a.id,
                               reader: MainVC.CreateNewsReader())
            }
        }
    }
    
    let tmpPath = "/Users/mbergamo/tmp"
    
    public func uudecode(args : [String], filename: String, encodedFile: String) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/uudecode"
        task.arguments = args
        task.currentDirectoryPath = tmpPath
        let inputpipe = Pipe()
        task.standardInput = inputpipe
        task.launch()
        if let data = encodedFile.data(using: .utf8) {
            inputpipe.fileHandleForWriting.write(data)
        }
        task.waitUntilExit()
        let status = task.terminationStatus
        if status != 0 {
            if FileManager.default.fileExists(atPath: "/Users/mbergamo/tmp/\(filename)") {
                return 0
            }
        }
        return (status)
    }
    
    public func open(fileName: String) -> Int32 {
        var name = fileName
//        if name.contains(" ") {
//            name = "'\(fileName)'"
//        }
        
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [name]
        //task.currentDirectoryPath = tmpPath
        task.launch()
        task.waitUntilExit()
        let status = task.terminationStatus
        return (status)
    }
    
    @IBOutlet var articleView: NSTextView!
    
    func formatOutput(output: String) -> NSMutableAttributedString {
        let font = NSFont(name: "Courier", size: 14)
        let attributedText = NSMutableAttributedString(string: output,
                                                       attributes: [NSAttributedString.Key.font: font])
        return attributedText
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
                            if line.contains(".jpg") || line.contains(".JPG") || line.contains(".gif") || line.contains(".GIF") {
                                // begin 600 HDV-HD-0089_050.jpg
                                let parts = line.split(separator: " ").map(String.init)
                                isImage = true
                                filename = parts[2]
                                for idx in 3..<parts.count {
                                    filename.append(" \(parts[idx])")
                                }
                                //print("Filename:\(filename):")
                            }
                        }
                        if line.starts(with: "end") {
                            endFound = true
                        }
                    }
                    
                    if (beginFound && endFound) {
                        //print("goooo")
                        if isImage {
                            let status = self.uudecode(args: [], filename: filename, encodedFile: article)
                            //print("Status: \(status)")
                            if (status == 0) {
                                self.open(fileName: "\(self.tmpPath)/\(filename)")
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
}
