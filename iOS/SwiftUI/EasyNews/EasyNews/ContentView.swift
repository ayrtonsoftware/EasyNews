//
//  ContentView.swift
//  EasyNews
//
//  Created by Michael Bergamo on 4/30/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import SwiftUI

struct ContentViewVM {
    @State var groups: [NewsGroupVM] = [NewsGroupVM]()
}

struct ContentView: View {
    @State private var vm: ContentViewVM!
    
    init(model: ContentViewVM) {
        vm = model
    }
    
    func onLoadGroups() {
        print("Load Groups")
        vm.groups.append(NewsGroupVM(name: "New \(Date())"))
    }
    
    func onGroupClicked(group: NewsGroupVM) {
        print("Group: \(group.name) selected")
    }
    
    var body: some View {
        NavigationView {
            MasterView(groups: $vm.groups)
                .navigationBarTitle(Text("Master"))
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            self.onLoadGroups()
                        }
                    ) {
                        Image(systemName: "plus")
                    }
                )
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct MasterView: View {
    @Binding var groups: [NewsGroupVM]

    var body: some View {
        List {
            ForEach(groups, id: \.self) { group in
                NavigationLink(
                    destination: DetailView(selectedGroup: group)
                ) {
                    Text("\(group.name)")
                }
            }.onDelete { indices in
                indices.forEach { self.groups.remove(at: $0) }
            }
        }
    }
}

struct DetailView: View {
    var selectedGroup: NewsGroupVM?

    var body: some View {
        Group {
            if selectedGroup != nil {
                Text("\(selectedGroup?.name ?? "N/A")")
            } else {
                Text("Detail view content goes here")
            }
        }.navigationBarTitle(Text("Detail"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ContentViewVM(groups: [
            NewsGroupVM(name: "Hello1"),
            NewsGroupVM(name: "Hello2"),
            NewsGroupVM(name: "Hello3"),
            NewsGroupVM(name: "Hello4"),
            NewsGroupVM(name: "Hello5"),
            NewsGroupVM(name: "Hello6")
        ])
        return ContentView(model: vm)
    }
}
