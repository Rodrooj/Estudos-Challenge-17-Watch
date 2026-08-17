//
//  WScrollView.swift
//  Watch Teste Watch App
//
//  Created by Rodrigo Barbosa Pereira on 17/08/26.
//

import SwiftUI

struct WScrollView: View {
    var body: some View {
        ScrollView(.vertical) {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                .font(.title)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    WScrollView()
}
