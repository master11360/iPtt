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
            print("[test] error: \(error)")
        }
        print("[test] shell started")
        startLocalEventMonitor()
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
                print("[test] input error: \(error)")
            }
        }
    }
    
    func startLocalEventMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: [NSEvent.EventTypeMask.keyDown], handler: { event in
            if let data = self.getCmdData(event) {
                self.writeDataToSocket(data)
            }
            return nil
        })
    }
    
    private func writeDataToSocket(_ data: Data) {
        do {
            try self.session.channel.write(data)
        } catch {
            print("[test] input error: \(error)")
        }
    }
    
    private func getCmdData(_ event: NSEvent) -> Data? {
        guard let characters = event.characters else { return nil }
        if characters.unicodeScalars.first == Unicode.Scalar(NSUpArrowFunctionKey) {
            return Data([0x1B, 0x5B, 0x41])
        } else if characters.unicodeScalars.first == Unicode.Scalar(NSDownArrowFunctionKey) {
            return Data([0x1B, 0x5B, 0x42])
        } else if characters.unicodeScalars.first == Unicode.Scalar(NSLeftArrowFunctionKey) {
            return Data([0x1B, 0x5B, 0x44])
        } else if characters.unicodeScalars.first == Unicode.Scalar(NSRightArrowFunctionKey) {
            return Data([0x1B, 0x5B, 0x43])
        }
        return event.characters?.data(using: .utf8)
    }
    
    private func removeHttpResponseStringIfNeeded(_ str: String) -> String {
        guard let firstNewlineIndex = str.firstIndex(where: { $0.isNewline }) else { return str }
        let strBeforeFirstNewline = String(str[..<firstNewlineIndex])
        guard strBeforeFirstNewline.lowercased().contains("http") else { return str }
        return String(str[firstNewlineIndex...])
    }
}

extension PttMgr: NMSSHChannelDelegate {
    func channel(_ channel: NMSSHChannel, didReadRawData data: Data) {
        var str = String(decoding: data, as: UTF8.self)
        str = removeHttpResponseStringIfNeeded(str)
        str = str.filter({ !$0.isNewline })
        print("[test] data: \(str)")
    }

    func channel(_ channel: NMSSHChannel, didReadRawError error: Data) {
        print("[test] error: \(error)")
    }
    
    func channelReadEnd(_ channel: NMSSHChannel) {
        guard let resp = channel.lastResponse else { return }
        if resp.contains(account) {
            input(password)
        }
    }
    
    func channel(_ channel: NMSSHChannel, didReadData message: String) {
        print("[test] message: \(message)")
    }
    
    func channel(_ channel: NMSSHChannel, didReadError error: String) {
        print("[test] error: \(error)")
    }
    
    func channelShellDidClose(_ channel: NMSSHChannel) {
        print("[test] shell closed")
    }
}
