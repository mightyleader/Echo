//
//  ContentView.swift
//  Echo
//
//  Created by Rob Stearn on 24/01/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var peerDatasource = PeerDatasource()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
