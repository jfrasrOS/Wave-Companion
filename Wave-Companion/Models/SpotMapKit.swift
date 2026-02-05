//
//  SpotMapKit.swift
//  Wave-Companion
//
//  Created by John on 05/02/2026.
//

import MapKit

extension Spot {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
