//
//  Chat.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import SwiftUI

struct Chat: View {
    
    var id:String
    var name:String
    var image: String
    @State private var message = ""
    @State private var sending = false
    @State private var sendingError = false
    @State private var loading = false
    @State private var error = ""
    @State private var showError = false
    @State private var foundUNREADAI = false
    @ObservedObject var viewModel = ChatroomsViewModel()

    init(id:String, name:String, image: String) {
        
        self.id = id
        self.name = name
        self.image = image
        
        viewModel.typing(id) { (done) in
            if done {
                print("all good")
            } else if !done {
                print("error getting typing status")
            }
        }
        
        viewModel.getMessages(id) { (done) in
            if done {
                print("all good")
            } else if !done {
                print("error occured while loading messages")
            }
        }
        
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {

        ZStack {

            Color("background")
                .ignoresSafeArea()

            VStack {
                VStack {
                    
                    if viewModel.loading {
                        Loading(loadingPercentage: viewModel.loadingPercentage)
                    } else {
                        if showError {
                            
                            Text(error)
                                .foregroundColor(.red)
                            
                        } else {
                            if viewModel.messages.count != 0 {
                                
                                ScrollView(.vertical) {
                                    ScrollViewReader { value in
                                        ForEach(viewModel.messages) { message in
                                            
                                            if viewModel.messages.firstIndex(of: message)! == (viewModel.messages.count - 1) {
                                                
                                                if message.mine {
                                                    if !message.seen {
                                                        MessageClassification(chatID: id, message: message, messages: viewModel.messages)
                                                            .padding(.bottom, 3)
                                                            .id(message.id)
                                                    } else {
                                                        MessageClassification(chatID: id, message: message, messages: viewModel.messages)
                                                            .id(message.id)
                                                    }
                                                } else {
                                                    MessageClassification(chatID: id, message: message, messages: viewModel.messages)
                                                        .padding(.bottom, 3)
                                                        .id(message.id)
                                                }
                                            } else {
                                                MessageClassification(chatID: id, message: message, messages: viewModel.messages)
                                                    .id(message.id)
                                            }
                                        }
                                        .onChange(of: viewModel.messages, perform: { change in
                                            value.scrollTo((viewModel.messages[viewModel.messages.count - 1]).id)
                                        })
                                        .onAppear(perform: {
                                            
                                            for x in viewModel.messages {
                                                if x.isAI {
                                                    if x.id.components(separatedBy: ".")[0] == "UNREADAI" {
                                                        if !x.mine {
                                                            foundUNREADAI = true
                                                            value.scrollTo(x.id)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            if !foundUNREADAI {
                                                value.scrollTo((viewModel.messages[viewModel.messages.count - 1]).id)
                                            }
                                        })
                                    }
                                }
                            } else {
                                Text("no messages")
                            }
                        }
                    }
                }

                Spacer()
                
                if viewModel.typing {
                    HStack {
                        VStack {
                            Text("typing...")
                        }
                        
                        Spacer()
                    }
                }

                Divider()

                ZStack {
                    HStack {
                        
                        TextEditor(text: $message)
                            .frame(width: .infinity, height: 28,alignment: .center)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 5)
                            .background(Color("searchBarColor"))
                            .cornerRadius(20)
                            .font(.system(size: 18))
                            .lineSpacing(-3)
                    }

                    HStack {

                        Button {

                        } label: {
                            Image(systemName:"plus")
                        }
                        .padding(.horizontal, 10)
                        .font(.system(size: 22))

                        Spacer()

                        Button {
                            
                            if message != "" && message != " " {
                                sending = true
                                
                                viewModel.sendMessage(id: id, message: message) { (done) in
                                    if !done {
                                        sendingError = true
                                        sending = false
                                    } else if done {
                                        sending = false
                                        sendingError = false
                                    }
                                }
                                
                                message = ""
                            }
                            
                        } label: {
                            Image(systemName:"paperplane")
                        }
                        .padding(.horizontal, 12)
                        .font(.system(size: 20))
                    }
                }
                .padding(.bottom, 2)

            }
            .onAppear(perform: {
                viewModel.inChat(true, id: id)
            })
            .onDisappear(perform: {
                viewModel.inChat(false, id: id)
            })
            .navigationBarTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing:
                    Button {
                
                    } label: {
                        Text("options")
                        Image(systemName: "")
                    }
                    .frame(width: 120, height: 40, alignment: .trailing)
            )
        }
    }
    
    func imageDecoder(image:String) -> UIImage {
        
        if image != "" {
            let decodedData: Data = Data(base64Encoded: image, options: .ignoreUnknownCharacters)!

            let decodedImage = UIImage(data: decodedData)

            return decodedImage!
        } else{
            return UIImage(systemName: "person.crop.circle")!
        }

    }
}
