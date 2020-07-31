//
//  ContentView.swift
//  iPtt
//
//  Created by Ming on 2020/7/29.
//  Copyright © 2020 Ming. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var account = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Text("Hello, World!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                TextField("Account", text: $account)
                Button(action: onLoginClicked) {
                    Text("Login")
                }.hidden()
            }
            HStack {
                SecureField("Password", text: $password)
                Button(action: onLoginClicked) {
                    Text("Login")
                }
            }
        }.padding()
    }
    
    func onLoginClicked() {
        if !account.isEmpty && !password.isEmpty {
//            pttMgr.login(account, password)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
