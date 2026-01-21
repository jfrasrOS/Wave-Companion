import SwiftUI
import FirebaseAuth

struct RegistrationProfileView: View {
    @EnvironmentObject var registrationVM: RegistrationViewModel
    @EnvironmentObject var session: SessionManager
    

    private var isFormValid: Bool {
        !registrationVM.data.name.isEmpty && registrationVM.selectedCountry != nil
    }

    var body: some View {
        ZStack {
           

            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 16) {

                        // Prénom
                        TextField("Prénom", text: $registrationVM.data.name)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.white))

                        // Nationalité
                        NavigationLink {
                            CountryPickerView()
                                .environmentObject(registrationVM)
                        } label: {
                            HStack {
                                Text(registrationVM.selectedCountry?.name ?? "Choisir une nationalité")
                                    .foregroundColor(registrationVM.selectedCountry == nil ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
                        }
                    }
                    .padding()
                }

                // Bouton Continuer
                Button {
                    continueToNextStep()
                } label: {
                    Text("Continuer")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.orange : Color.gray)
                        .cornerRadius(25)
                        .padding(.horizontal)
                }
                .disabled(!isFormValid)
            }
            .padding(.top)
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Navigation vers la prochaine étape
    private func continueToNextStep() {
        guard registrationVM.validateProfile() else { return }

        // Mise à jour de l'utilisateur temporaire (session.currentUser si Firebase Auth existe)
        if let _ = Auth.auth().currentUser {
            // On pourrait remplir la session temporaire si nécessaire
        }

        // Navigation vers l'étape suivante
        registrationVM.next(.surfLevel)
    }
}

