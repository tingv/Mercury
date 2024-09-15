//
//  MercuryApp.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 18/04/24.
//

import SwiftUI

@main
struct Mercury_Watch_AppApp: App {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @StateObject var vm = LoginViewModel()
    @WKApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            
            if let auth = vm.authenticated {
                if auth || vm.useMock {
                    SettingsView(useMock: vm.useMock)
                } else {
                    LoginView()
                }
            } else {
                ProgressView()
            }
                
            
        }
        .environmentObject(vm)
        .onChange(of: isLuminanceReduced) {
            if isLuminanceReduced {
                LoginViewModel.setOfflineStatus()
            } else {
                LoginViewModel.setOnlineStatus()
            }
        }
    }
}
