//
//  MeetupMapPickerView.swift
//  Wave-Companion
//
//  Created by John on 19/05/2026.
//

import SwiftUI
import MapKit

struct MeetupMapPickerView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var latitude: Double?
    @Binding var longitude: Double?

    // Spot sélectionné depuis SurfMap
    let spotLatitude: Double
    let spotLongitude: Double

    @State private var cameraPosition: MapCameraPosition

    // Coordonnée exacte sous le pin fixe
    @State private var selectedCoordinate: CLLocationCoordinate2D

    init(
        latitude: Binding<Double?>,
        longitude: Binding<Double?>,
        spotLatitude: Double,
        spotLongitude: Double
    ) {

        self._latitude = latitude
        self._longitude = longitude

        self.spotLatitude = spotLatitude
        self.spotLongitude = spotLongitude

        // Si user a déjà choisi un point :  on revient dessus sinon centre sur le spot
        let initialCoordinate = CLLocationCoordinate2D(
            latitude: latitude.wrappedValue ?? spotLatitude,
            longitude: longitude.wrappedValue ?? spotLongitude
        )

        // Coordonnée réelle sauvegardée
        _selectedCoordinate = State(
            initialValue: initialCoordinate
        )

        // Zoom précis si point déjà choisi - plus large au premier affichage
        let initialRegion = MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(
                latitudeDelta:
                    latitude.wrappedValue != nil
                    ? 0.0012
                    : 0.0055,

                longitudeDelta:
                    longitude.wrappedValue != nil
                    ? 0.0012
                    : 0.0055
            )
        )

        _cameraPosition = State(
            initialValue: .region(initialRegion)
        )
    }

    var body: some View {

        ZStack {

            Map(
                position: $cameraPosition,
                interactionModes: [.pan, .zoom]
            )
            .mapStyle(.standard)
            .ignoresSafeArea()
            .onMapCameraChange(
                frequency: .continuous
            ) { context in

                selectedCoordinate =
                    context.camera.centerCoordinate
            }

            VStack {

                ZStack {

                    Rectangle()
                        .fill(AppColors.action)
                        .frame(width: 2, height: 30)
                        .offset(y: 16)

                    Circle()
                        .fill(AppColors.action)
                        .frame(width: 5, height: 5)
                        .offset(y: 31)

                    Circle()
                        .fill(AppColors.action)
                        .frame(width: 22, height: 22)
                }

                Spacer()
            }
            .padding(.top, 318)
            .allowsHitTesting(false)


            VStack {

                Spacer()

                Button {

                    // Sauvegarde coordonnée EXACTE
                    latitude =
                        selectedCoordinate.latitude

                    longitude =
                        selectedCoordinate.longitude

                    dismiss()

                } label: {

                    Text("Confirmer ce point")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(AppColors.primary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
