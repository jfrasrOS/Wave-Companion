//
//  SpotClusterMapView.swift
//  Wave-Companion
//
//  Created by John on 05/02/2026.
//

import SwiftUI
import MapKit

// View MapKit avec clustering des spots et sélection
struct SpotClusterMapView: UIViewRepresentable {

    let spots: [Spot]
    @Binding var selectedSpotIDs: Set<String>
    @Binding var focusedSpotID: String?

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        map.showsCompass = false
        map.showsScale = false

        // Enregistrement des vues pour annotations et clusters
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "spot")
        map.register(MKMarkerAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)

        // Centrer sur la France par défaut
        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4),
                                         span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)),
                      animated: false)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        // On supprime toutes les annotations pour les mettre à jour
        map.removeAnnotations(map.annotations)

        let annotations = spots.map { spot -> MKPointAnnotation in
            let a = MKPointAnnotation()
            a.title = spot.name
            a.subtitle = spot.id
            a.coordinate = spot.coordinate
            return a
        }

        map.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        let parent: SpotClusterMapView

        init(_ parent: SpotClusterMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

            // Cluster
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: cluster
                ) as! MKMarkerAnnotationView
                view.canShowCallout = false
                view.clusteringIdentifier = "spots"
                view.markerTintColor = .systemBlue
                view.glyphText = "\(cluster.memberAnnotations.count)"
                view.glyphTintColor = .white
                view.displayPriority = .required
                return view
            }

            // Spot individuel
            guard let annotation = annotation as? MKPointAnnotation else { return nil }

            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: "spot",
                for: annotation
            ) as! MKMarkerAnnotationView

            view.clusteringIdentifier = "spots"
            view.canShowCallout = false

            let id = annotation.subtitle ?? ""
            let isSelected = parent.selectedSpotIDs.contains(id)
            let isFocused = parent.focusedSpotID == id

            view.markerTintColor = isSelected ? UIColor(AppColors.action) : .white
            view.glyphImage = UIImage(systemName: "wave.3.right")
            view.glyphTintColor = isSelected ? .white : .black
            view.transform = isFocused ? CGAffineTransform(scaleX: 1.25, y: 1.25) : .identity
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

            // Si c'est un cluster, zoomer automatiquement sur tous les spots
            if let cluster = view.annotation as? MKClusterAnnotation {
                let coords = cluster.memberAnnotations.map { $0.coordinate }
                let region = MKCoordinateRegion(coords: coords)
                mapView.setRegion(region, animated: true)
                return
            }

            // Spot isolé : sélectionner / désélectionner
            guard let annotation = view.annotation as? MKPointAnnotation,
                  let id = annotation.subtitle else { return }

            if parent.selectedSpotIDs.contains(id) {
                parent.selectedSpotIDs.remove(id)
            } else if parent.selectedSpotIDs.count < 3 {
                parent.selectedSpotIDs.insert(id)
            }

            parent.focusedSpotID = id
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}
