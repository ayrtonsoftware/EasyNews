//
//  NewsReaderModels.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/30/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

struct NewsGroupVM: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var first: Int
    var last: Int
    var progress: Double = 0.0
    
    public init(group: NewsGroup) {
        self.name = group.name
        self.first = group.first.value ?? 0
        self.last = group.last.value ?? 0
    }
    
    public init(name: String) {
        self.name = name
        self.first = 0
        self.last = 0
        self.progress = 0.0
    }
}
