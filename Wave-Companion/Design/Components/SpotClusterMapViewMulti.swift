//
//  SpotClusterMapViewMulti.swift
//  Wave-Companion
//
//  Created by John on 06/03/2026.
//

import Foundation
import SwiftUI
import MapKit


// MapView pour le choix des spots favoris (inscription)
struct SpotClusterMapViewMulti: UIViewRepresentable {
    
    let spots: [Spot]
    let hasSession: (Spot) -> Bool
    let maxSelection: Int
    
    @Binding var selectedSpotIDs: Set<String>
    @Binding var focusedSpotID: String?
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        map.showsCompass = false
        map.showsScale = false
        
        // Annotations
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "spot")
        
        // Vue pour les clusters
        map.register(MKMarkerAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        // Région initiale (centrée sur la France)
        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4),
                                         span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)),
                      animated: false)
        return map
    }
    
    // Mise à jour de la map si changement
    func updateUIView(_ map: MKMapView, context: Context) {
        
        // Supprime tout
        map.removeAnnotations(map.annotations)
        
        // crée une annotation pour chaque spot
        let annotations = spots.map { spot -> MKPointAnnotation in
            let a = MKPointAnnotation()
            a.title = spot.name
            a.subtitle = spot.id
            a.coordinate = spot.coordinate
            return a
        }
        
        // Ajoute les annoations à la map
        map.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: SpotClusterMapViewMulti
        
        init(_ parent: SpotClusterMapViewMulti) {
            self.parent = parent
        }
        
        // crée les annoations (pins/clusters)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            // Cas 1 : cluster (plusieurs spots regroupés)
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: cluster
                ) as! MKMarkerAnnotationView
                view.canShowCallout = false
                view.clusteringIdentifier = "spots"
                
                view.markerTintColor = .systemGray
                view.glyphText = "\(cluster.memberAnnotations.count)"
                view.glyphTintColor = .white
                view.displayPriority = .required
                return view
            }
            
            // Cas 2 : pin individuelle
            guard let annotation = annotation as? MKPointAnnotation,
                  let spot = parent.spots.first(where: { $0.id == annotation.subtitle }) else { return nil }
            
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: "spot",
                for: annotation
            ) as! MKMarkerAnnotationView
            
            view.clusteringIdentifier = "spots"
            view.canShowCallout = false
            
            // vérifie si spot selectionné
            let isSelected = parent.selectedSpotIDs.contains(spot.id)
            
            view.markerTintColor = isSelected ? UIColor(AppColors.action) : .white
            view.glyphImage = UIImage(systemName: "wave.3.right")
            view.glyphTintColor = isSelected ? .white : .black
            
            // petit zoom si le spot est focus
            let isFocused = parent.focusedSpotID == spot.id
            view.transform = isFocused ? CGAffineTransform(scaleX: 1.25, y: 1.25) : .identity
            
            return view
        }
        
        // Gestion du tap sur une annotation
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            // Si on clique sur le cluster -> zoom sur la zone
            if let cluster = view.annotation as? MKClusterAnnotation {
                let coords = cluster.memberAnnotations.map { $0.coordinate }
                let region = MKCoordinateRegion(coords: coords)
                mapView.setRegion(region, animated: true)
                return
            }
            
            // Si on clique sur un spot
            guard let annotation = view.annotation as? MKPointAnnotation,
                  let id = annotation.subtitle else { return }
            
            if parent.selectedSpotIDs.contains(id) {
                parent.selectedSpotIDs.remove(id)
            } else if parent.selectedSpotIDs.count < parent.maxSelection {
                parent.selectedSpotIDs.insert(id)
            }
            
            parent.focusedSpotID = id
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}
