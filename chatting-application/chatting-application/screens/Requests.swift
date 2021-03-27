//
//  requests.swift
//  chatting-application
//
//  Created by Omar Amer on 07/03/2021.
//

import SwiftUI

struct Requests: View {
    
    @State private var requestPanel = "received"
    @State private var receivedCount = ""
    @State private var sentCount = ""
    
    var body: some View {
        
        ZStack {
            
            Color("background")
                .ignoresSafeArea()
                
            VStack {
                Picker("requests", selection: $requestPanel, content: {
                    Text("Received \(receivedCount)").tag("received")
                    
                    Text("Sent \(sentCount)").tag("sent")
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                
                if requestPanel == "received" {
                    
                } else if requestPanel == "sent" {
                    
                }
                
                Spacer()
            }
        }
        .navigationTitle("Requests")
    }
}
