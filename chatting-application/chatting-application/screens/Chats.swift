//
//  Chats.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import SwiftUI

struct Chats: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @ObservedObject var viewModel = ChatroomsViewModel()
    @State private var toSettings = false
    @State private var showSearch = false
    @State private var toCreateGroup = false
    
    init() {
        viewModel.fetchData()
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                Color("background")
                    .ignoresSafeArea()
                
                VStack {
                    
                    if viewModel.loading {
                        Loading(loadingPercentage: viewModel.loadingPercentage)
                    } else {
                        if viewModel.chatrooms.count >= 1 {

                            ForEach(viewModel.chatrooms) { (chatroom) in
                                chatsList(id: chatroom.id, name: chatroom.title, profileImage: chatroom.image, new:chatroom.new, lastMessage: chatroom.lastMessage, time: chatroom.time, typing: chatroom.typing, unreadMessages: chatroom.unreadMessages)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 5)
                                
                                if viewModel.chatrooms[(viewModel.chatrooms.count - 1)].id != chatroom.id {
                                    
                                    Divider()
                                        .padding(.horizontal, 15)
                                }
                                
                            }

                        } else if viewModel.chatrooms.count == 0 {

                            Text("No chats started. press the New Chats button to start a new chat.")
                                .padding(50)
                        }
                    }

                    Spacer()
                    
                    NavigationLink(
                        destination: Settings(),
                        isActive: $toSettings,
                        label: {
                            EmptyView()
                        })
                    
                    NavigationLink(
                        destination: Search(),
                        isActive: $showSearch,
                        label: {
                            EmptyView()
                        })
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Chats")
            .navigationBarItems(
                
                leading:
                    Button {
                        toSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                    },
                
                trailing:
                    Button {
                        showSearch = true
                    } label: {
                        
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                        
                    }
            )
            
        }
    }
}
