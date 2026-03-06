import SwiftUI

struct CreateSessionView: View {

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var vm: SessionViewModel

    @State private var sessionDate = Date()
    @State private var minLevel = "Débutant"
    @State private var maxPeople = 4

    let levels = ["Débutant","Intermédiaire","Confirmé","Expert"]

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                DatePicker(
                    "Date & heure",
                    selection: $sessionDate
                )

                Picker("Niveau minimum", selection: $minLevel) {
                    ForEach(levels, id: \.self) {
                        Text($0)
                    }
                }

                HStack {

                    Text("Participants max")

                    Spacer()

                    Stepper(value: $maxPeople, in: 1...12) {
                        Text("\(maxPeople)")
                    }
                }

                Spacer()

                Button {

                    Task {

                        await vm.createSession(
                            date: sessionDate,
                            minLevel: minLevel,
                            maxPeople: maxPeople
                        )

                        dismiss()
                    }

                } label: {

                    Text("Créer la session")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Nouvelle session")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
