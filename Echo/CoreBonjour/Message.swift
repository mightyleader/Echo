//
//  Message.swift
//  LocalTalk
//
//  Created by Robert Stearn on 11/07/2019.
//  Copyright © 2019 Cocoadelica. All rights reserved.
//

import Foundation
import SwiftUI

public enum MessageSource: String, Codable {
    case me = "me"
    case them = "them"
}

public struct Message: Hashable, Codable, Identifiable {
    public let id: Int
    public let content: String
    public let source: MessageSource
    public let correspondent: String
    public let dateStamp: Double
    //  let peer: Peer // Reserved for future expansion :)
}
