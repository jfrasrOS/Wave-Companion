//
//  GeoHash.swift
//  Wave-Companion
//
//  Created by John on 10/03/2026.
//

import Foundation
import CoreLocation

struct GeoHash {

    static func encode(latitude: Double, longitude: Double, length: Int = 6) -> String {

        let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")

        var latRange = (-90.0, 90.0)
        var lonRange = (-180.0, 180.0)

        var hash = ""
        var bit = 0
        var ch = 0
        var even = true

        while hash.count < length {

            if even {
                let mid = (lonRange.0 + lonRange.1) / 2
                if longitude > mid {
                    ch |= 1 << (4 - bit)
                    lonRange.0 = mid
                } else {
                    lonRange.1 = mid
                }
            } else {
                let mid = (latRange.0 + latRange.1) / 2
                if latitude > mid {
                    ch |= 1 << (4 - bit)
                    latRange.0 = mid
                } else {
                    latRange.1 = mid
                }
            }

            even.toggle()

            if bit < 4 {
                bit += 1
            } else {
                hash.append(base32[ch])
                bit = 0
                ch = 0
            }
        }

        return hash
    }
}
