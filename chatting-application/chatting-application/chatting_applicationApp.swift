//
//  chatting_applicationApp.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import SwiftUI
import Firebase
import UserNotifications

@main
struct chatting_applicationApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    @ObservedObject var viewModel = ChatroomsViewModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        viewModel.online()
        print("launching finished")
        return true
    }
}
