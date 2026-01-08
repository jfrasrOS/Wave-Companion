import SwiftUI

struct RegistrationProfileView: View {

    @EnvironmentObject var vm: RegistrationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Photo picker
                ProfilePhotoPicker(vm: vm)

                // Champs texte
                Group {
                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Nom", text: $vm.data.name)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(vm.errorMessages["name"] != nil ? Color.red : Color.gray.opacity(0.5)))
                        if let error = vm.errorMessages["name"] {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Email", text: $vm.data.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(vm.errorMessages["email"] != nil ? Color.red : Color.gray.opacity(0.5)))
                        if let error = vm.errorMessages["email"] {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        SecureField("Mot de passe", text: $vm.data.password)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(vm.errorMessages["password"] != nil ? Color.red : Color.gray.opacity(0.5)))
                        if let error = vm.errorMessages["password"] {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        SecureField("Confirmer le mot de passe", text: $vm.confirmPassword)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(vm.errorMessages["confirmPassword"] != nil ? Color.red : Color.gray.opacity(0.5)))
                        if let error = vm.errorMessages["confirmPassword"] {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        NavigationLink {
                            CountryPickerView()
                        } label: {
                            HStack {
                                Text(vm.selectedCountry?.flag ?? "🌍")
                                Text(vm.selectedCountry?.name ?? "Choisir une nationalité")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(vm.errorMessages["nationality"] != nil ? .red : .gray.opacity(0.5))
                            )
                        }

                    }
                }

                // Bouton Continuer
                Button {
                    
                        if vm.validateProfile() {
                            // Vérification données récupérés
                            print("Pays sélectionné :", vm.selectedCountry?.name ?? "aucun")
                            print("Code stocké :", vm.data.nationality)
                            print("User :", vm.data.name, vm.data.email)
                            
                            //Vérification photo
                            if !vm.data.profileImage.isEmpty {
                                print("Photo présente, taille :", vm.data.profileImage.count, "caractères")
                            } else {
                                print("Pas de photo")
                            }

                            vm.next(.surfLevel)
                        
                    }
                } label: {
                    Text("Continuer")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            vm.data.name.isEmpty ||
                            vm.data.email.isEmpty ||
                            vm.data.password.isEmpty ||
                            vm.confirmPassword.isEmpty ||
                            vm.selectedCountry == nil
                            ? Color.gray
                            : Color.blue
                        )
                        .cornerRadius(12)
                }
                .disabled(
                    vm.data.name.isEmpty ||
                    vm.data.email.isEmpty ||
                    vm.data.password.isEmpty ||
                    vm.confirmPassword.isEmpty ||
                    vm.selectedCountry == nil
                )

            }
            .padding()
        }
        .navigationTitle("Profil")
    }
}

