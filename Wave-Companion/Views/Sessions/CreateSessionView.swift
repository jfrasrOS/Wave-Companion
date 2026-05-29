
import SwiftUI
import MapKit
import CoreLocation

struct CreateSessionView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: SessionViewModel

    @State private var sessionDate = Date().maximumSessionDate()

    @State private var maxPeople = 4
    @State private var minLevelId = "mousse_1"

    @State private var meetupNote = ""

    @State private var meetupLatitude: Double?
    @State private var meetupLongitude: Double?

    @State private var showMapPicker = false
    @State private var showDatePicker = false
    
    @State private var meetupAddress = ""

    let levelCategories: [(label: String, id: String)] = [
        ("Débutant", "mousse_1"),
        ("Intermédiaire", "bronze_1"),
        ("Confirmé", "argent_2"),
        ("Expert", "or_2")
    ]

    var allowedLevels: [(label: String, id: String)] {

        guard let userLevelId = vm.currentUserLevelId,
              let userOrder = vm.levelOrder(for: userLevelId)
        else {
            return []
        }

        return levelCategories.filter { level in

            guard let levelOrder = vm.levelOrder(for: level.id)
            else {
                return false
            }

            return levelOrder <= userOrder
        }
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottom) {

                ScrollView(showsIndicators: false) {

                    VStack(alignment: .leading, spacing: 12) {

                        HStack {
                            Spacer()

                            Capsule()
                                .fill(Color.secondary.opacity(0.25))
                                .frame(width: 38, height: 5)

                            Spacer()
                        }
                        .padding(.top, 8)

                            Text("Crée une session en quelques secondes")
                                .font(.headline)
                                .padding(.top, 10)

                        SessionSectionTitle(title: "Quand ?")
                            .padding(.top, 10)

                        Button {
                            showDatePicker.toggle()
                        } label: {

                            HStack {
                                
                                    Image(systemName: "calendar")
                                      .font(.title3)
                                      .foregroundColor(AppColors.primary)
                              
                                    Text(sessionDate.formattedDateCard)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(AppColors.primary.opacity(0.6))
                              
                            }
                            .padding(20)
                
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(AppColors.primary.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .sheet(isPresented: $showDatePicker) {

                            PremiumDatePickerSheet(
                                selectedDate: $sessionDate
                            )
                        }

                        
                        // LEVEL
                        SessionSectionTitle(title: "Niveau minimum")
                            .padding(.top, 10)

                        ScrollView(.horizontal, showsIndicators: false) {

                            HStack(spacing: 12) {

                                ForEach(allowedLevels, id: \.id) { level in

                                    let isSelected = minLevelId == level.id

                                    Button {
                                        minLevelId = level.id
                                    } label: {

                                        Text(level.label)
                                            .font(.footnote.weight(.semibold))
                                            .foregroundColor(
                                                isSelected
                                                ? .white
                                                : .primary
                                            )
                                            .padding(.horizontal, 16)
                                            .frame(height: 40)
                                            .background(
                                                isSelected
                                                ? AppColors.primary
                                                : Color(.systemGray6)
                                            )
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        // PARTICIPANTS
                        SessionSectionTitle(title: "Participants max")
                            .padding(.top, 10)

                        HStack {

                                Text("\(maxPeople) personnes")
                                    .font(.headline)

                            Spacer()

                            HStack(spacing: 0) {

                                Button {

                                    if maxPeople > 2 {
                                        maxPeople -= 1
                                    }

                                } label: {

                                    Image(systemName: "minus")
                                        .font(.headline)
                                        .frame(width: 52, height: 52)
                                }

                                Divider()
                                    .frame(height: 26)

                                Button {

                                    if maxPeople < 8 {
                                        maxPeople += 1
                                    }

                                } label: {

                                    Image(systemName: "plus")
                                        .font(.headline)
                                        .frame(width: 52, height: 52)
                                }
                            }
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppColors.primary.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
                        )

                        // Point de rencontre
                        SessionSectionTitle(title: "Point de rencontre")
                            .padding(.top, 10)

                        Button {
                            showMapPicker.toggle()
                        } label: {

                            HStack(spacing: 16) {

                                VStack(alignment: .leading, spacing: 6) {

                                    Text(
                                        meetupLatitude == nil
                                        ? "Choisir sur la carte"
                                        : meetupAddress
                                    )
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                    Text(
                                        meetupLatitude == nil
                                        ? "Aide les participants à se retrouver"
                                        : "Les participants verront ce point"
                                    )
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "location.fill")
                                    .font(.title2)
                                    .foregroundColor(AppColors.action)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(AppColors.primary.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .sheet(isPresented: $showMapPicker) {

                            if let selectedSpot = vm.spots.first(
                                where: {
                                    $0.id == vm.selectedSpotID
                                }
                            ) {

                                MeetupMapPickerView(
                                    latitude: $meetupLatitude,
                                    longitude: $meetupLongitude,
                                    spotLatitude: selectedSpot.latitude,
                                    spotLongitude: selectedSpot.longitude
                                )
                            }
                        }
                        
                        // Infos
                        SessionSectionTitle(title: "Informations complémentaires (optionnel)")
                            .padding(.top, 10)

                        TextField(
                            "Parking sud, près du poste de secours...",
                            text: $meetupNote,
                            axis: .vertical
                        )
                        .lineLimit(3, reservesSpace: true)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppColors.primary.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.primary.opacity(0.08), lineWidth: 1)
                        )

                        Spacer(minLength: 140)
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }

                VStack {

                    Button {

                        Task {

                            await vm.createSession(
                                date: sessionDate,
                                minLevel: minLevelId,
                                maxPeople: maxPeople,
                                meetupLatitude: meetupLatitude,
                                meetupLongitude: meetupLongitude,
                                meetupNote: meetupNote
                            )

                            dismiss()
                        }

                    } label: {

                        Text("Créer la session")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(AppColors.primary)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.96),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .onChange(of: meetupLatitude) {

            updateMeetupAddress()
        }
    }
    
    func updateMeetupAddress() {

        guard let latitude = meetupLatitude,
              let longitude = meetupLongitude
        else {
            return
        }

        let location = CLLocation(
            latitude: latitude,
            longitude: longitude
        )

        CLGeocoder().reverseGeocodeLocation(location) {
            placemarks,
            error in

            guard let placemark = placemarks?.first else {
                return
            }

            let place =
                placemark.name
                ?? placemark.locality
                ?? "Point sélectionné"

            DispatchQueue.main.async {

                meetupAddress = place
            }
        }
    }
}



// TITRES
struct SessionSectionTitle: View {

    let title: String

    var body: some View {

        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.secondary)
    }
}

// DATE
struct PremiumDatePickerSheet: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var selectedDate: Date

    var body: some View {

        NavigationStack {

            VStack {

                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: Date().minimumSessionDate()...Date().maximumSessionDate(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .navigationTitle("Choisir une date")
            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button("OK") {
                        dismiss()
                    }
                }
            }
        }
    }
}






