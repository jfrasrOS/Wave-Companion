//
//  AuthChoiceView.swift
//  Wave-Companion
//
//  Created by John on 03/12/2025.
//

import SwiftUI

struct AuthChoiceView: View {
    var body: some View {
        VStack{
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()
            
            Text("Wave Companion")
            
           
            Button("Inscription"){
                // Sign Up
            }
            .buttonStyle(.borderedProminent)
            
            Button("Connexion"){
                // Login
            }
            .buttonStyle(.bordered)
            
        }
        .padding()
    }
}

#Preview {
    AuthChoiceView()
}
