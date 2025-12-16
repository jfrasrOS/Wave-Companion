//
//  RegistrationBoardView.swift
//  Wave-Companion
//
//  Created by John on 04/12/2025.
//

import SwiftUI

struct RegistrationBoardView: View {

    @EnvironmentObject var vm: RegistrationViewModel

    var body: some View {
        Form {
            Text("Choix de planche")
                .font(.title.bold())

            TextField("Type de planche", text: $vm.data.boardType)
            TextField("Couleur de la planche", text: $vm.data.boardColor)

            Button("Continuer") {
                vm.next(.spots)
            }
        }
        .navigationTitle("Planche")
    }
}


#Preview {
    RegistrationBoardView()
        .environmentObject(RegistrationViewModel())
}
