//
//  settings.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import SwiftUI

struct Settings: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("accentColor") private var accentColor = "purple"
    @ObservedObject var sessionStore = SessionStore()
    @ObservedObject var viewModel = ChatroomsViewModel()

    init() {
        viewModel.getUserData()
    }
    
    var body: some View {
        
        ZStack {

            Color("background")
                .ignoresSafeArea()

            VStack {
                
                VStack {
                    Image(uiImage: imageDecoder(image: viewModel.currentUser[0].image))
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                    
                    Text(viewModel.currentUser[0].username)
                    Text(viewModel.currentUser[0].email)
                    
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                VStack {
                    Text("Background")

                    Picker("mode", selection: $isDarkMode) {
                        Text("Light")
                            .tag(false)
                        Text("Dark")
                            .tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Settings")

        }
        .navigationBarItems(
            trailing:
                Button("Logout") {
                    sessionStore.signOut()
                }
        )
    }
}
