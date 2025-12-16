//
//  RegistrationSurfLevelView.swift
//  Wave-Companion
//
//  Created by John on 04/12/2025.
//
import SwiftUI

struct RegistrationSurfLevelView: View {

    @EnvironmentObject var vm: RegistrationViewModel
    
    var levels = ["Débutant", "Intermédiaire", "Avancé"]
    
    var body: some View {
        Form {
            Text("Ton niveau de surf")
                .font(.title.bold())
            
            Picker("Niveau", selection: $vm.data.surfLevel) {
                ForEach(levels, id: \.self) { level in
                    Text(level)
                }
            }
            
            Button("Continuer") {
                vm.next(.board)
            }
        }
        .navigationTitle("Niveau surf")
    }
}

#Preview {
    RegistrationSurfLevelView()
        .environmentObject(RegistrationViewModel())
}
