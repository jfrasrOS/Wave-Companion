//
//  RegistrationProfileView.swift
//  Wave-Companion
//
//  Created by John on 04/12/2025.
//

import SwiftUI

struct RegistrationProfileView: View {

    @EnvironmentObject var vm: RegistrationViewModel
    
    var body: some View {
        Form {
            Text("Ton profil")
                .font(.title.bold())
            
            TextField("Nom", text: $vm.data.name)
            TextField("Email", text: $vm.data.email)
            SecureField("Mot de passe", text: $vm.data.password)
            TextField("Nationalité", text: $vm.data.nationality)
            
            Button("Continuer") {
                vm.next(.surfLevel)
            }
        }
        .navigationTitle("Profil")
        
    }
    
}

#Preview {
    RegistrationProfileView()
        .environmentObject(RegistrationViewModel())
}

        

