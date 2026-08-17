//
//  WTabView.swift
//  Watch Teste Watch App
//
//  Created by Rodrigo Barbosa Pereira on 17/08/26.
//

import SwiftUI

struct ContentView: View {
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
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text("Bye, world!")
            }
            .padding()
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    ContentView()
}
