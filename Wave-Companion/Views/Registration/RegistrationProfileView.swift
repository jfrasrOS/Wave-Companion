import SwiftUI
import FirebaseAuth

struct RegistrationProfileView: View {

    @EnvironmentObject var registrationVM: RegistrationViewModel
    @EnvironmentObject var session: SessionManager

    private var isFormValid: Bool {
        !registrationVM.data.name.isEmpty &&
        registrationVM.selectedCountry != nil
    }

    var body: some View {
        RegistrationStepContainer(
            title: "Faisons connaissance !",
            subtitle: "Ces infos nous aident à personnaliser ton expérience.",
            currentStep: 0,
            totalSteps: 4,
            isActionEnabled: isFormValid,
            onBack: { registrationVM.back() },
            onAction: continueToNextStep
        ) {

           

            TextField("Prénom", text: $registrationVM.data.name)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6))
                )

            NavigationLink {
                CountryPickerView()
                    .environmentObject(registrationVM)
            } label: {
                HStack {
                    
                            // Drapeau (uniquement si un pays est sélectionné)
                            if let country = registrationVM.selectedCountry {
                                Text(country.flag)
                                    .font(.title3)
                            }

                    Text(registrationVM.selectedCountry?.name ?? "Choisir une nationalité")
                        .foregroundColor(registrationVM.selectedCountry == nil ? .gray : .primary)
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
        .navigationBarTitleDisplayMode(.inline)
    }

    private func continueToNextStep() {
        guard registrationVM.validateProfile() else { return }
        registrationVM.next(.surfLevel)
    }
}

