//
//  Data.swift
//  LocalTalk
//
//  Created by Robert Stearn on 17/06/2019.
//  Copyright © 2019 Cocoadelica. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public class MessageData: ObservableObject, Identifiable {
    public var peerData: [Peer] = [Peer]()
    public var messageData: [Message] = [Message]()
    public var objectWillChange = PassthroughSubject<Void, Never>()
    
    init() {
        self.setupDummyData()
    }
    
    private func setupDummyData() {
        self.peerData = self.load("peerData.json")
        self.messageData = self.load("messageData.json")
    }
    
    func addMessage(message: String, sender: MessageSource, name: String) {
        let newMessage = Message(id: Date().hashValue,
                                 content: message,
                                 source: sender,
                                 correspondent: name,
                                 dateStamp: Date().timeIntervalSince1970)
        messageData.append(newMessage)
        self.objectWillChange.send()
    }
    
    func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // TODO: Handle error correctly
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    func interpretIncoming(data sent: Data) {
        do {
            let receivedTransmission = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(sent) as! [String: Any]
            // DEBUG
            print(receivedTransmission)
            self.addMessage(message: receivedTransmission["messagePayload"] as! String,
                            sender: .them,
                            name: receivedTransmission["messageSender"] as! String)
        } catch {
            // TODO: Handle error correctly
            print("FAILED DECODING THING")
        }
    }
}
