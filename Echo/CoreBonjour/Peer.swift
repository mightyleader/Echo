//
//  Peer.swift
//  LocalTalk
//
//  Created by Robert Stearn on 17/06/2019.
//  Copyright © 2019 Cocoadelica. All rights reserved.
//

import Foundation
import SwiftUI

public struct Peer: Hashable, Codable, Identifiable {
    public var id: Int
    public var displayName: String
    public var connected: Bool
}


