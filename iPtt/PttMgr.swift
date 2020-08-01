//
//  PttMgr.swift
//  iPtt
//
//  Created by Ming on 2020/7/31.
//  Copyright © 2020 Ming. All rights reserved.
//

import NMSSH

class PttMgr: NSObject {
    let host = "ptt.cc"
    let username = "bbsu"
    var session: NMSSHSession
    private var account = ""
    private var password = ""
    
    override init() {
        session = NMSSHSession(host: host, andUsername: username)
        super.init()
        session.connect()
        guard session.isConnected else { return }
        session.authenticate(byPassword: "")
        guard session.isAuthorized else { return }
        session.channel.delegate = self
//        session.channel.bufferSize = 65536
        do {
            try session.channel.startShell()
        } catch {
            print("error: \(error)")
        }
        print("shell started")
    }
    
    func login(_ account: String, _ password: String) {
        self.account = account
        self.password = password
        input(account)
    }
    
    func input(_ input: String) {
        let msg = "\(input)\r"
        if let data = msg.data(using: .utf8) {
            do {
                try session.channel.write(data)
            } catch {
                print("input error: \(error)")
            }
        }
    }
}

extension PttMgr: NMSSHChannelDelegate {
    func channel(_ channel: NMSSHChannel, didReadRawData data: Data) {
        print("data: \(data)")
    }

    func channel(_ channel: NMSSHChannel, didReadRawError error: Data) {
        print("error: \(error)")
    }
    
    func channelReadEnd(_ channel: NMSSHChannel) {
        guard let resp = channel.lastResponse else { return }
        if resp.contains(account) {
            input(password)
        }
    }
    
    func channel(_ channel: NMSSHChannel, didReadData message: String) {
        print("message: \(message)")
    }
    
    func channel(_ channel: NMSSHChannel, didReadError error: String) {
        print("error: \(error)")
    }
    
    func channelShellDidClose(_ channel: NMSSHChannel) {
        print("shell closed")
    }
}
