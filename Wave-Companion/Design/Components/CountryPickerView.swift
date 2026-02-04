import SwiftUI

struct CountryPickerView: View {

    @EnvironmentObject var vm: RegistrationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""

    // Filtre
    private var filteredCountries: [Country] {
        if searchText.isEmpty {
            return vm.countries
        }

        return vm.countries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(filteredCountries) { country in
            Button {
                vm.selectedCountry = country
                vm.data.nationality = country.id
                dismiss()
            } label: {
                HStack(spacing: 12) {

                    // Drapeau
                    Text(country.flag)
                        .font(.title2)

                    // Nom du pays
                    Text(country.name)
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()

                    // Check si sélectionné
                    if vm.selectedCountry == country {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.plain)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Rechercher un pays"
        )
        .navigationTitle("Nationalité")
        .navigationBarTitleDisplayMode(.inline)
    }
}

