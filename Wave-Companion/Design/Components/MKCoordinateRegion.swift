//
//  MKCoordinateRegion.swift
//  Wave-Companion
//
//  Created by John on 05/02/2026.
//

import MapKit

// Permet de créer un MKCoordinateRegion automatiquement autour d'une liste de coordonnées
extension MKCoordinateRegion {
    init(coords: [CLLocationCoordinate2D]) {
        guard !coords.isEmpty else {
            self.init(center: CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4),
                      span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7))
            return
        }

        let latitudes = coords.map { $0.latitude }
        let longitudes = coords.map { $0.longitude }

        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLon = longitudes.max()!
        let minLon = longitudes.min()!

        let center = CLLocationCoordinate2D(
            latitude: (maxLat + minLat) / 2,
            longitude: (maxLon + minLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )

        self.init(center: center, span: span)
    }
}
