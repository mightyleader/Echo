//
//  ContentView.swift
//  Echo
//
//  Created by Rob Stearn on 24/01/2024.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @ObservedObject var peerDatasource = PeerDatasource()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "bonjour")
                    .imageScale(.large)
                    .foregroundColor(peerDatasource.sessionState ? .orange : .gray)
                .foregroundStyle(.tint)
                Text("Session running")
            }
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(peerDatasource.advertiserActive ? .orange : .gray)
                .foregroundStyle(.tint)
                Text("Advertising active")
            }
            HStack {
                Image(systemName: "magnifyingglass.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(peerDatasource.browserActive ? .orange : .gray)
                .foregroundStyle(.tint)
                Text("Browsing for peers")
            }
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(peerDatasource.found ? .orange : .gray)
                .foregroundStyle(.tint)
                Text("Found peers")
            }
        }
        .padding()

    }
}

#Preview {
    ContentView()
}
