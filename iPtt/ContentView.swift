//
//  ContentView.swift
//  iPtt
//
//  Created by Ming on 2020/7/29.
//  Copyright © 2020 Ming. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let pttMgr = PttMgr()
    @State private var account = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Text(pttMgr.pageModel.curPage)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.padding()
    }
    
    func onLoginClicked() {
        if !account.isEmpty && !password.isEmpty {
            pttMgr.login(account, password)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
