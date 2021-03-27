//
//  CreateGroup.swift
//  chatting-application
//
//  Created by Omar Amer on 07/03/2021.
//

import SwiftUI

struct CreateGroup: View {
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            
            VStack {
                Text("this page is to create a new group")
            }
        }
        .navigationTitle("New Group")
    }
}
