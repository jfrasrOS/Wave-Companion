//
//  RegistrationFavoritesSpotsView.swift
//  Wave-Companion
//
//  Created by John on 04/12/2025.
//

import SwiftUI


struct RegistrationFavoritesSpotsView: View {

    @EnvironmentObject var vm: RegistrationViewModel
    
    var body: some View {
        VStack {
            Text("Spots préférés")
                .font(.title)

            Button("Terminer inscription") {
                let user = vm.register()
                print("Utilisateur final ->", user)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Spots")
    }
}



#Preview {
    RegistrationFavoritesSpotsView()
        .environmentObject(RegistrationViewModel())
}
