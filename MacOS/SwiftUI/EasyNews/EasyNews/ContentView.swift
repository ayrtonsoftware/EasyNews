//
//  ContentView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/30/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var groups: [NewsGroupVM] = []
    
    init(groups: [NewsGroupVM]) {
        self.groups = groups
    }
    
    func onGroupClicked(group: NewsGroupVM) {
        print("Group: \(group.name) selected")
    }
    
    var body: some View {
        HStack {
            List {
                Section(header: Text("Group")) {
                    ForEach(groups) {
                        group in
                        Button(action: {
                            self.onGroupClicked(group: group)
                        }) {                            
                            Text(group.name)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView(groups: [
            NewsGroupVM(name: "Hello1"),
            NewsGroupVM(name: "Hello2"),
            NewsGroupVM(name: "Hello3"),
            NewsGroupVM(name: "Hello4"),
            NewsGroupVM(name: "Hello5"),
            NewsGroupVM(name: "Hello6")
        ])
    }
}
