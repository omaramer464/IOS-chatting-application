//
//  search.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import SwiftUI

struct Search: View {
    @State private var search = ""
    @State private var error = ""
    @State private var showError = false
    
    @ObservedObject var viewModel = ChatroomsViewModel()

    var body: some View {
        ZStack {

            Color("background")
                .ignoresSafeArea()
            
            VStack {
                inputField(name: "Search", saving: $search, secure: false)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Color("searchBarColor"))
                    .cornerRadius(10)
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.primary)
                    .onChange(of: search, perform: { value in

                        if search == "" {
                            viewModel.searchResults = []
                        } else {
                            viewModel.Search(search, handler: { (done) in
                                if !done {
                                    error = "an error occured while searching"
                                    showError = true
                                }
                            })
                        }
                    })

                    
                if viewModel.searchResults.count >= 1 {
                    ForEach(viewModel.searchResults) { (result) in
                        SearchList(uid: result.id, image: result.image, name: result.username, status: result.status)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                        
                        if viewModel.searchResults[(viewModel.searchResults.count - 1)].username != result.username {
                            
                            Divider()
                                .padding(.horizontal, 15)
                        }
                        
                    }
                } else if viewModel.searchResults.count == 0 {
                    Text("no username found.")
                }

                Spacer()
            }

        }
        .navigationTitle("Search")
    }
}
