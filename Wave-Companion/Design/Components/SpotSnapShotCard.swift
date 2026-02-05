//
//  SpotSnapShotCard.swift
//  Wave-Companion
//
//  Created by John on 05/02/2026.
//

import SwiftUI
import MapKit

// Card pour afficher le spot sélectionné avec image satellite
struct SpotSnapshotCard: View {

    let spot: Spot
    let isFocused: Bool
    let onRemove: () -> Void

    @State private var image: UIImage?
    
    // récupère le scale correct de l'écran
    @Environment(\.displayScale) private var displayScale

    // Dimensions fixes pour que toutes les cartes aient la même taille
    private let cardWidth: CGFloat = 220
    private let imageHeight: CGFloat = 120

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Fond gris pendant le chargement
                Color.gray.opacity(0.2)
                    .frame(height: imageHeight)

                // Affichage de l'image satellite si chargée
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: imageHeight)
                        .clipped()
                }
            }

            // Infos du spot et bouton supprimer
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(spot.name)
                        .font(.headline)
                    Text("\(spot.city)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding(8)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(width: cardWidth)
        .scaleEffect(x: isFocused ? 1.05 : 1, y: 1, anchor: .center)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isFocused)
        .onAppear {
            loadSnapshot()
        }
    }

    // Charge l'image satellite du spot via MKMapSnapshotter
    private func loadSnapshot() {
            let options = MKMapSnapshotter.Options()
            options.mapType = .satellite
            options.size = CGSize(width: cardWidth * displayScale,
                                  height: imageHeight * displayScale)
            options.scale = displayScale
            options.region = MKCoordinateRegion(center: spot.coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

            MKMapSnapshotter(options: options).start { snapshot, _ in
                if let snapshotImage = snapshot?.image {
                    DispatchQueue.main.async {
                        self.image = snapshotImage.resize(to: CGSize(width: cardWidth, height: imageHeight))
                    }
                }
            }
        }
}

// Extension pour redimensionner UIImage
extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
