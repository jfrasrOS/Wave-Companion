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
                    VStack(alignment: .leading, spacing: 28) {
                        
                        // Titre + sous-texte
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Faisons connaissance !")
                                .font(.title)
                                .fontWeight(.bold)
                              
                                                    
                            Text("Pas d’inquiétude, on utilise ça seulement pour te retrouver sur les spots et personnaliser ton expérience.")
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true) // pour que le texte fasse un retour à la ligne si nécessaire
                        }
                        .padding(.horizontal)
                        .padding(.bottom)

                        // Prénom
                        TextField("Prénom", text: $registrationVM.data.name)
                            .padding()

                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemGray6))
                            )
                           

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
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    .padding()
                }

                // Bouton Continuer
                Button {
                    continueToNextStep()
                } label: {
                    Text("Continuer")
                        .font(.headline)
                        .foregroundColor(isFormValid ? Color.white : AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? AppColors.action : Color.white )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(isFormValid ? Color.clear : AppColors.primary, lineWidth: 2)
                        )
                        .cornerRadius(25)
                        .padding(.horizontal)
                }
                .disabled(!isFormValid)
            }
            .padding(.top)
        }
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

#Preview {
    RegistrationProfileView()
        .environmentObject(RegistrationViewModel())
        .environmentObject(SessionManager())
}
