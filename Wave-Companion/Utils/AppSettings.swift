//
//  AppSettings.swift
//  Wave-Companion
//
//  Created by John on 29/04/2026.
//

import UIKit

// Ouvrir Réglages pur accéder à la localisation
func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
}
