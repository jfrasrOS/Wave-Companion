//
//  Wave_CompanionApp.swift
//  Wave-Companion
//
//  Created by John on 25/11/2025.
//

import SwiftUI
import SwiftData

@main
struct Wave_CompanionApp: App {
    
    @State private var isLoading = true
    @State private var isUserLoggedIn = false


    var body: some Scene {
        WindowGroup {
            if isLoading{
                LoadingView()
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
            } else {
                if isUserLoggedIn {
                    ContentView()
                } else {
                    AuthChoiceView()
                }
            }
        }
       
    }
}
