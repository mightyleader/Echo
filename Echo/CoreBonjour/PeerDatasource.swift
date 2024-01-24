//
//  ContentView.swift
//  LocalTalk
//
//  Created by Robert Stearn on 17/06/2019.
//  Copyright © 2019 Cocoadelica. All rights reserved.
//

import SwiftUI
import Combine
import MultipeerConnectivity

class PeerDatasource: NSObject, ObservableObject, Identifiable, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    typealias PublishType = (Data?, Peer?)
    
    let objectWillChange = PassthroughSubject<PublishType,Never>()
    var session: MCSession?
    var peers: [Peer] {
        if let session = self.session {
            return self.peerFactory(mcpeers: session.connectedPeers)
        }
        return [Peer]()
    }
    
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    var peerID: String = UUID().uuidString {
        didSet {
            self.teardown()
            self.setup()
        }
    }
    
    override init() {
        super.init()
        self.setup()
    }
    
    func setup() -> Void {
        let peerIDObject = MCPeerID(displayName: self.peerID)
        
        //Session
        self.session = MCSession(peer: peerIDObject)
        self.session?.delegate = self
        
        //Browse
        self.browser = MCNearbyServiceBrowser(peer: peerIDObject, serviceType:"LocalTalk")
        self.browser?.delegate = self
        self.browser?.startBrowsingForPeers()
        
        //Advertise
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerIDObject, discoveryInfo: nil, serviceType: "LocalTalk")
        self.advertiser?.delegate = self
        self.advertiser?.startAdvertisingPeer()
    }
    
    func teardown() -> Void {
        if self.session != nil {
            if let advertiser = self.advertiser,
               let browser = self.browser {
                advertiser.stopAdvertisingPeer()
                browser.stopBrowsingForPeers()
            }
            self.session = nil
        }
    }
    
    private func peerFactory(mcpeers: [MCPeerID]) -> [Peer] {
        return mcpeers.map { mcpeer in
                Peer(id: mcpeer.hash, displayName: mcpeer.displayName, connected: true)
            }
    }
    
    func checkConnection(for peer: Peer) -> Bool {
        if let session = self.session {
            let matches = session.connectedPeers.filter { $0.displayName == peer.displayName}
            return matches.count > 0 ? true : false
        }
        return false
    }
    
    func peer(for mcpeer: MCPeerID) -> Peer? {
        let matches = self.peers.filter { $0.displayName == mcpeer.displayName }
        return matches.count > 0 ? matches.first : nil
    }
    
    func send(message text: String, to peer: Peer) -> Void {
        let transmissionHash = ["messageSender": peer.displayName,
                                "messagePayload":text,
                                "messageTimestamp": Date(),
                                "messagePeerList":[peer.displayName, self.session?.myPeerID.displayName]] as [String : Any]
        do {
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: transmissionHash, requiringSecureCoding: false)
            do {
                try self.session!.send(archivedData,
                                       toPeers: self.session!.connectedPeers,
                                       with: .reliable)
            } catch {
                // TODO: Handle error correctly
                print("MESSAGE SEND FAILED")
            }
        } catch {
            // TODO: Handle error correctly
            print("DATA ARCHIVED FAILED")
        }
    }
    
    //MARK: Session Delegate
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async(execute: {
            self.objectWillChange.send((nil, nil))
        })
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            let delegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
            delegate.datasource.interpretIncoming(data: data)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not implemented
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not implemented
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not implemented
    }
    
    //MARK: Browser Delegate
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        // TODO: Handle browsing failing to start
        print("ERROR")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found: \(peerID.displayName)")
        self.browser?.invitePeer(peerID, to: self.session!, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async(execute: {
            self.objectWillChange.send((nil, nil))
        })
    }
    
    //MARK: Advertiser delegate
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
    
}

