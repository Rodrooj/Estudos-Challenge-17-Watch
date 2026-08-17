//
//  WTabView.swift
//  Watch Teste Watch App
//
//  Created by Rodrigo Barbosa Pereira on 17/08/26.
//

import SwiftUI

struct WTabView: View {
    var body: some View {
        TabView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text("Hello, world!")
            }
            .padding()
            
            VStack {
                Image(systemName: "hand.wave")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text("Bye, world!")
            }
            .padding()
            
            WScrollView()
            
            WWorkout()
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    WTabView()
}
