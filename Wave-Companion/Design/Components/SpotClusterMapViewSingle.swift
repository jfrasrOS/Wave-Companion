import SwiftUI
import MapKit

class SpotAnnotation: NSObject, MKAnnotation {
    let spot: Spot
    var coordinate: CLLocationCoordinate2D { spot.coordinate }
    var title: String? { spot.name }
    var subtitle: String? { spot.id }
    
    init(spot: Spot) {
        self.spot = spot
    }
}

// MapView pour la SurfMapView (session / spots)
struct SpotClusterMapViewSingle: UIViewRepresentable {
    
    let spots: [Spot]
    let hasSession: (Spot) -> Bool
    
    @Binding var selectedSpotID: String?
    @Binding var focusedSpotID: String?
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        map.showsCompass = false
        map.showsScale = false
        
        // Enregistrement des vues
        map.register(PinAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
        map.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.6, longitude: 2.4),
                                         span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)),
                      animated: false)
        return map
    }
    
    func updateUIView(_ map: MKMapView, context: Context) {

        let existing = map.annotations.compactMap { $0 as? SpotAnnotation }
        let existingIDs = Set(existing.map { $0.spot.id })

        let newIDs = Set(spots.map { $0.id })

        // annotations à supprimer
        let toRemove = existing.filter { !newIDs.contains($0.spot.id) }

        // annotations à ajouter
        let toAdd = spots
            .filter { !existingIDs.contains($0.id) }
            .map { SpotAnnotation(spot: $0) }

        map.removeAnnotations(toRemove)
        map.addAnnotations(toAdd)

        // refresh visuel des vues existantes (sessions / sélection)
        for annotation in existing {
            if let view = map.view(for: annotation) as? PinAnnotationView {
                let hasSession = hasSession(annotation.spot)
                let isSelected = selectedSpotID == annotation.spot.id
                view.configure(hasSession: hasSession, isSelected: isSelected)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: SpotClusterMapViewSingle
        
        init(_ parent: SpotClusterMapViewSingle) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            // Cluster
            if let cluster = annotation as? MKClusterAnnotation {
                let clusterView = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: cluster) as! ClusterAnnotationView
                
                // Vérifier si au moins un spot du cluster a une session
                let hasSessionInCluster = cluster.memberAnnotations.contains { member in
                    guard let spotAnnotation = member as? SpotAnnotation else { return false }
                    return parent.hasSession(spotAnnotation.spot)
                }
                
                clusterView.configure(memberCount: cluster.memberAnnotations.count, hasSession: hasSessionInCluster)
                return clusterView
            }
            
            // Spot individuel
            guard let spotAnnotation = annotation as? SpotAnnotation else { return nil }
            
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation) as! PinAnnotationView
            let isSelected = parent.selectedSpotID == spotAnnotation.spot.id
            let hasSession = parent.hasSession(spotAnnotation.spot)
            pinView.configure(hasSession: hasSession, isSelected: isSelected)
            
            return pinView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let cluster = view.annotation as? MKClusterAnnotation {
                let coords = cluster.memberAnnotations.map { $0.coordinate }
                let region = MKCoordinateRegion(coords: coords)
                mapView.setRegion(region, animated: true)
                return
            }
            
            guard let annotation = view.annotation as? SpotAnnotation else { return }
            parent.selectedSpotID = annotation.spot.id
            parent.focusedSpotID = annotation.spot.id
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}

// Pin individuel
class PinAnnotationView: MKMarkerAnnotationView {
    func configure(hasSession: Bool, isSelected: Bool) {
        clusteringIdentifier = "spots"
        canShowCallout = false
        markerTintColor = hasSession ? .systemBlue : (isSelected ? UIColor(AppColors.action) : .white)
        glyphImage = hasSession ? UIImage(systemName: "figure.surfing") : UIImage(systemName: "wave.3.right")
        glyphTintColor = (hasSession || isSelected) ? .white : .black
        addSessionBadge(hasSession)
    }
    
    private func addSessionBadge(_ show: Bool) {
        subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        guard show else { return }
        let badge = UIView(frame: CGRect(x: -5, y: -5, width: 10, height: 10))
        badge.backgroundColor = .systemRed
        badge.layer.cornerRadius = 5
        badge.layer.borderWidth = 1
        badge.layer.borderColor = UIColor.white.cgColor
        badge.tag = 999
        addSubview(badge)
    }
}

// Cluster
class ClusterAnnotationView: MKMarkerAnnotationView {

    private let badgeLayer = CALayer()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        clusteringIdentifier = "spots"
        canShowCallout = false
        displayPriority = .required

        badgeLayer.backgroundColor = UIColor.systemRed.cgColor
        badgeLayer.cornerRadius = 5
        badgeLayer.borderWidth = 1
        badgeLayer.borderColor = UIColor.white.cgColor
        badgeLayer.isHidden = true

        layer.addSublayer(badgeLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // position pastille en haut à gauche du cluster
        badgeLayer.frame = CGRect(x: -4, y: -4, width: 10, height: 10)
    }

    func configure(memberCount: Int, hasSession: Bool) {

        glyphText = "\(memberCount)"
        glyphTintColor = .white

        markerTintColor = hasSession ? .systemBlue : .systemGray

        badgeLayer.isHidden = !hasSession
    }
}
