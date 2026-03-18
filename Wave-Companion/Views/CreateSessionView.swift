import SwiftUI

struct CreateSessionView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: SessionViewModel

    @State private var sessionDate = Date().minimumSessionDate()
    @State private var pickerDate = Date().minimumSessionDate()

   
    @State private var maxPeople = 4

    let levelCategories: [(label: String, id: String)] = [
        ("Débutant", "mousse_1"),
        ("Intermédiaire", "bronze_1"),
        ("Confirmé", "argent_2"),
        ("Expert", "or_2")
    ]

    @State private var minLevelId = "mousse_1"
    
    var allowedLevels: [(label: String, id: String)] {
        guard let userLevelId = vm.currentUserLevelId,
              let userOrder = vm.levelOrder(for: userLevelId)
        else {
            return []
        }

        return levelCategories.filter { level in
            guard let levelOrder = vm.levelOrder(for: level.id) else { return false }
            return levelOrder <= userOrder
        }
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                // Date & heure
                DatePicker(
                    "Date & heure",
                    selection: $pickerDate,
                    in: Date().minimumSessionDate()...,
                    displayedComponents: [.date, .hourAndMinute]
                )

                // Niveau minimum
                Picker("Niveau minimum", selection: $minLevelId) {
                    ForEach(allowedLevels, id: \.id) { level in
                        Text(level.label)
                            .tag(level.id)
                    }
                }

                // Participants max
                HStack {
                    Text("Participants max")
                    Spacer()
                    Stepper(value: $maxPeople, in: 2...12) {
                        Text("\(maxPeople)")
                    }
                }

                Spacer()

                // Bouton créer session
                Button {
                    Task {
                        await vm.createSession(
                            date: sessionDate,
                            minLevel: minLevelId,
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

        // Si User reste longtemps sur la page, mise à jour de la date minimale
        .onAppear {
            let minDate = Date().minimumSessionDate()
            sessionDate = minDate
            pickerDate = minDate
        }

        // Arrondi au quart d’heure supérieur + contrôle du minimum
        .onChange(of: pickerDate) { _, newValue in
            let rounded = newValue.roundedUpToQuarterHour()
            let minDate = Date().minimumSessionDate()

            if rounded < minDate {
                sessionDate = minDate
                pickerDate = minDate
            } else {
                sessionDate = rounded
                pickerDate = rounded
            }
        }
    }
}


extension Date {

    // Minimum autorisé : maintenant + 30 minutes arrondi au quart d’heure supérieur
    func minimumSessionDate() -> Date {
        let calendar = Calendar.current

        let plus30 = calendar.date(byAdding: .minute, value: 30, to: self)!

        let minutes = calendar.component(.minute, from: plus30)
        let remainder = minutes % 15
        let add = remainder == 0 ? 0 : 15 - remainder

        let rounded = calendar.date(byAdding: .minute, value: add, to: plus30)!

        var comps = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: rounded)
        comps.second = 0
        comps.nanosecond = 0

        return calendar.date(from: comps)!
    }

    // Arrondi quart d’heure supérieur
    func roundedUpToQuarterHour() -> Date {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)

        let remainder = minutes % 15
        let add = remainder == 0 ? 0 : 15 - remainder

        let rounded = calendar.date(byAdding: .minute, value: add, to: self)!

        return calendar.date(bySetting: .second, value: 0, of: rounded)!
    }
}
