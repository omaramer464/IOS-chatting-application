//
//  Loading.swift
//  chatting-application
//
//  Created by Omar Amer on 26/03/2021.
//

import SwiftUI

struct Loading: View {
    
    var loadingPercentage: CGFloat = 0.0
    
    var body: some View {
        HStack {
            HStack {
                
            }
            .frame(width: loadingPercentage * 400, height: 2, alignment: .leading)
            .background(Color.accentColor)
            .animation(.easeIn(duration: 0.3))
            
            Spacer(minLength: 0)
        }
        .frame(width: 400, height: 2, alignment: .center)
        .padding(.vertical, 5)
    }
}
