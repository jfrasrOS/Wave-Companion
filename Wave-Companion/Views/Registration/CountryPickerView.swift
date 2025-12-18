import SwiftUI

struct CountryPickerView: View {

    @EnvironmentObject var vm: RegistrationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(vm.countries) { country in
            Button {
                vm.selectedCountry = country
                vm.data.nationality = country.id
                dismiss()
            } label: {
                HStack(spacing: 12) {
                    Text(country.flag)
                        .font(.largeTitle)

                    Text(country.name)
                        .font(.body)

                    Spacer()

                    if vm.selectedCountry == country {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Nationalité")
    }
}

