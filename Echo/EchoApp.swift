//
//  EchoApp.swift
//  Echo
//
//  Created by Rob Stearn on 24/01/2024.
//

import SwiftUI

@main
struct EchoApp: App {
    @EnvironmentObject var messageDatasource: MessageData
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
