//
//  ContentView.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @ObservedObject var sessionStore = SessionStore()
    
    init() {
        sessionStore.listen()
    }
    
    var body: some View {
        
        ZStack {
            Color("background")
                .ignoresSafeArea()
            
            Chats()
                .fullScreenCover(isPresented: $sessionStore.isAnon, content: {
                    Login()
                        .colorScheme(isDarkMode ? .dark : .light)
                })
                .colorScheme(isDarkMode ? .dark : .light)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
