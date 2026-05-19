import SwiftUI
import MapKit


final class SpotAnnotation: NSObject, MKAnnotation {

    // Spot associé au pin
    let spot: Spot

    // Coordonnées MapKit du spot
    var coordinate: CLLocationCoordinate2D {
        spot.coordinate
    }

    init(spot: Spot) {
        self.spot = spot
    }
}


struct SpotClusterMapViewSingle: UIViewRepresentable {

    let spots: [Spot]
    
    // Vérifie si un spot possède une session ouverte
    let hasOpenSession: (Spot) -> Bool
    // Vérifie si un spot possède uniquement des sessions complètes
    let hasOnlyFullSession: (Spot) -> Bool
    // Spot actuellement selectionné
    @Binding var selectedSpotID: String?
    // Spot à focus depuis la recherche
    @Binding var focusedSpotID: String?
    // région affiché sur la map
    @Binding var region: MKCoordinateRegion
    // Centre visuellement le spot entre search bar et bottom sheet
    let focusOffsetRatio: CGFloat

    var onRegionChanged: ((MKCoordinateRegion) -> Void)?

    // Coordinateur UIKit / MapKit
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {

        // Création map native iOS
        let map = MKMapView()

        map.delegate = context.coordinator

        map.isRotateEnabled = false
        map.showsCompass = false
        map.showsScale = false

        // Cache les points d'intérêt Apple Maps
        map.pointOfInterestFilter = .excludingAll

        // Enregistre les vues des pins
        map.register(
            PremiumPinAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: "pin"
        )

        // Enregistre les vues des clusters
        map.register(
            PremiumClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier:
                MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )

        // Région initiale map
        map.setRegion(region, animated: false)

        return map
    }

    // Synchronisation SwiftUI -> MapKit
    func updateUIView(
        _ map: MKMapView,
        context: Context
    ) {

        // Région actuelle de la map
        let current = map.region.center
        let target = region.center

        if abs(current.latitude - target.latitude) > 0.01 ||
            abs(current.longitude - target.longitude) > 0.01 {

            // Déplace la map vers la région cible
            map.setRegion(region, animated: true)
        }

        // Pins déjà affichés
        let existingAnnotations =
            map.annotations.compactMap {
                $0 as? SpotAnnotation
            }

        let existingIDs = Set(
            existingAnnotations.map {
                $0.spot.id
            }
        )

        // Ids des spots à afficher
        let newIDs = Set(
            spots.map {
                $0.id
            }
        )

        let annotationsToRemove =
            existingAnnotations.filter {
                !newIDs.contains($0.spot.id)
            }

        let annotationsToAdd =
            spots
            .filter {
                !existingIDs.contains($0.id)
            }
            .map {
                SpotAnnotation(spot: $0)
            }

        if !annotationsToRemove.isEmpty {

            // Supprime les anciens pins
            map.removeAnnotations(
                annotationsToRemove
            )
        }

        if !annotationsToAdd.isEmpty {

            // Ajoute les nouveaux pins
            map.addAnnotations(
                annotationsToAdd
            )
        }

        // Refresh manuel des styles visibles
        for annotation in map.annotations {

            guard let view =
                map.view(for: annotation)
            else {
                continue
            }

            // Pin
            if let spotAnnotation =
                annotation as? SpotAnnotation,

               let pinView =
                view as? PremiumPinAnnotationView {

                // Vérifie si le spot a une session ouverte
                let hasOpen =
                    hasOpenSession(
                        spotAnnotation.spot
                    )
                // Vérifie si le spot est complet
                let hasFullOnly =
                    !hasOpen &&
                    hasOnlyFullSession(
                        spotAnnotation.spot
                    )
                // Vérifie si le spot est sélectionné
                let isSelected =
                    selectedSpotID ==
                    spotAnnotation.spot.id

                pinView.configure(
                    hasOpen: hasOpen,
                    hasFullOnly: hasFullOnly,
                    isSelected: isSelected
                )
            }

            // Cluster
            else if let cluster =
                annotation as? MKClusterAnnotation,

                    let clusterView =
                    view as? PremiumClusterAnnotationView {
                // Spots contenus dans le cluster
                let clusterSpots =
                    cluster.memberAnnotations.compactMap {
                        ($0 as? SpotAnnotation)?.spot
                    }

                let hasOpen =
                    clusterSpots.contains {
                        hasOpenSession($0)
                    }

                let hasFullOnly =
                    !hasOpen &&
                    clusterSpots.contains {
                        hasOnlyFullSession($0)
                    }

                clusterView.configure(
                    count: cluster.memberAnnotations.count,
                    hasOpen: hasOpen,
                    hasFullOnly: hasFullOnly
                )
            }
        }
    }
}


extension SpotClusterMapViewSingle {

    final class Coordinator:
    NSObject,
    MKMapViewDelegate {

        let parent: SpotClusterMapViewSingle

        init(_ parent: SpotClusterMapViewSingle) {
            self.parent = parent
        }

        // Détecte déplacement / zoom map
        func mapView(
            _ mapView: MKMapView,
            regionDidChangeAnimated animated: Bool
        ) {

            // Synchronisation SwiftUI
            DispatchQueue.main.async {

                self.parent.region = mapView.region

                self.parent.onRegionChanged?(
                    mapView.region
                )
            }
        }

        // Création des vues MapKit
        func mapView(
            _ mapView: MKMapView,
            viewFor annotation: MKAnnotation
        ) -> MKAnnotationView? {

            if annotation is MKUserLocation {
                return nil
            }

            if let cluster =
                annotation as? MKClusterAnnotation {

                // Réutilisation vue cluster
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier:
                        MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: cluster
                ) as! PremiumClusterAnnotationView

                // Spots présents dans le cluster
                let spots = cluster.memberAnnotations.compactMap {
                    ($0 as? SpotAnnotation)?.spot
                }

                let hasOpen = spots.contains {
                    parent.hasOpenSession($0)
                }

                let hasFullOnly =
                    !hasOpen &&
                    spots.contains {
                        parent.hasOnlyFullSession($0)
                    }

                view.configure(
                    count: cluster.memberAnnotations.count,
                    hasOpen: hasOpen,
                    hasFullOnly: hasFullOnly
                )

                return view
            }

            guard let annotation =
                annotation as? SpotAnnotation else {
                return nil
            }

            // Réutilisation vue pin
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: "pin",
                for: annotation
            ) as! PremiumPinAnnotationView

            let hasOpen =
                parent.hasOpenSession(annotation.spot)

            let hasFullOnly =
                !hasOpen &&
                parent.hasOnlyFullSession(annotation.spot)

            let isSelected =
                parent.selectedSpotID ==
                annotation.spot.id

            view.configure(
                hasOpen: hasOpen,
                hasFullOnly: hasFullOnly,
                isSelected: isSelected
            )

            return view
        }

        // Gestion tap utilisateur
        func mapView(
            _ mapView: MKMapView,
            didSelect view: MKAnnotationView
        ) {

        
            if let cluster =
                view.annotation as? MKClusterAnnotation {

                // Coordonnées des pins du cluster
                let coords = cluster.memberAnnotations.map {
                    $0.coordinate
                }

                let region = MKCoordinateRegion(
                    coords: coords
                )

                // Zoom sur le cluster
                mapView.setRegion(
                    region,
                    animated: true
                )

                return
            }

    
            guard let annotation =
                view.annotation as? SpotAnnotation else {
                return
            }

            // Coordonnées réelle du spot selectionné
            let coordinate = annotation.coordinate

            // Décale la latitude vers le bas pour que le pin apparaisse plus haut
            let adjustedCenter = CLLocationCoordinate2D(
                latitude: coordinate.latitude - parent.focusOffsetRatio,
                longitude: coordinate.longitude
            )

            // Même niveau de zoom que celui de la barre de recherche
            let focusedRegion = MKCoordinateRegion(
                center: adjustedCenter,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.035,
                    longitudeDelta: 0.035
                )
            )

            // Animation
            mapView.setRegion(
                focusedRegion,
                animated: true
            )

            DispatchQueue.main.async {

                // Synchronise la région UIkit -> SwiftUI
                self.parent.region = focusedRegion
                // affiche le bottomsheet correspondant
                self.parent.selectedSpotID =
                    annotation.spot.id
            }

            UIImpactFeedbackGenerator(
                style: .light
            ).impactOccurred()

            mapView.deselectAnnotation(
                annotation,
                animated: false
            )
        }
    }
}


// PIN
final class PremiumPinAnnotationView:
MKAnnotationView {

    private let outerView = UIView()
    private let innerView = UIView()

    private var currentHasOpen = false
    private var currentHasFullOnly = false
    private var currentSelected = false

    override init(
        annotation: MKAnnotation?,
        reuseIdentifier: String?
    ) {

        super.init(
            annotation: annotation,
            reuseIdentifier: reuseIdentifier
        )

        clusteringIdentifier = "spots"

        collisionMode = .circle

        displayPriority = .defaultHigh

        canShowCallout = false

        bounds = CGRect(
            x: 0,
            y: 0,
            width: 24,
            height: 24
        )

        centerOffset = .zero

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        clusteringIdentifier = "spots"

        displayPriority = .defaultHigh

        currentHasOpen = false
        currentHasFullOnly = false
        currentSelected = false

        transform = .identity
    }

    override func prepareForDisplay() {

        super.prepareForDisplay()

        applyStyle()
    }

    // Construction visuelle du pin
    private func setup() {

        backgroundColor = .clear

        outerView.frame = bounds

        outerView.layer.cornerRadius = 12

        addSubview(outerView)

        innerView.frame = CGRect(
            x: 6,
            y: 6,
            width: 12,
            height: 12
        )

        innerView.layer.cornerRadius = 6

        outerView.addSubview(innerView)
    }

    // Configure état visuel du pin
    func configure(
        hasOpen: Bool,
        hasFullOnly: Bool,
        isSelected: Bool
    ) {

        currentHasOpen = hasOpen
        currentHasFullOnly = hasFullOnly
        currentSelected = isSelected

        applyStyle()
    }

    // Applique le style selon l'état
    private func applyStyle() {

        outerView.layer.shadowOpacity = 0
        outerView.layer.shadowRadius = 0
        outerView.layer.shadowColor = nil

        // Open
        if currentHasOpen {

            outerView.backgroundColor =
                UIColor(AppColors.primary)

            outerView.layer.borderWidth = 1.5

            outerView.layer.borderColor =
                UIColor.white.cgColor

            outerView.layer.shadowColor =
                UIColor(AppColors.primary).cgColor

            outerView.layer.shadowOpacity = 0.28

            outerView.layer.shadowRadius = 10

            outerView.layer.shadowOffset = .zero
        }

        // Full
        else if currentHasFullOnly {

            outerView.backgroundColor =
                UIColor(AppColors.action)

            outerView.layer.borderWidth = 1.5

            outerView.layer.borderColor =
                UIColor.white.cgColor

            outerView.layer.shadowColor =
                UIColor(AppColors.action).cgColor

            outerView.layer.shadowOpacity = 0.22

            outerView.layer.shadowRadius = 8

            outerView.layer.shadowOffset = .zero
        }

        // Vide
        else {

            outerView.backgroundColor = .white

            outerView.layer.borderWidth = 1.2

            outerView.layer.borderColor =
                UIColor(AppColors.primary).cgColor

            outerView.layer.shadowColor =
                UIColor.black.cgColor

            outerView.layer.shadowOpacity = 0.08

            outerView.layer.shadowRadius = 6

            outerView.layer.shadowOffset =
                CGSize(width: 0, height: 3)
        }

        innerView.isHidden = true

        // Agrandit le pin sélectionné
        transform =
            currentSelected
            ? CGAffineTransform(
                scaleX: 1.25,
                y: 1.25
            )
            : .identity
    }
}


// CLUSTER
final class PremiumClusterAnnotationView:
MKAnnotationView {

    private let bubbleView = UIView()

    private let countLabel = UILabel()

    private var currentCount = 0
    private var currentHasOpen = false
    private var currentHasFullOnly = false

    override init(
        annotation: MKAnnotation?,
        reuseIdentifier: String?
    ) {

        super.init(
            annotation: annotation,
            reuseIdentifier: reuseIdentifier
        )

        collisionMode = .circle

        displayPriority = .required

        canShowCallout = false

        bounds = CGRect(
            x: 0,
            y: 0,
            width: 44,
            height: 44
        )

        centerOffset = .zero

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        currentCount = 0
        currentHasOpen = false
        currentHasFullOnly = false
    }

    override func prepareForDisplay() {

        super.prepareForDisplay()

        applyStyle()
    }

    // Construction visuelle du cluster
    private func setup() {

        backgroundColor = .clear

        bubbleView.frame = bounds

        bubbleView.layer.cornerRadius = 22

        addSubview(bubbleView)

        countLabel.frame = bounds

        countLabel.font = .systemFont(
            ofSize: 16,
            weight: .bold
        )

        countLabel.textAlignment = .center

        addSubview(countLabel)
    }

    // Configure état visuel du cluster
    func configure(
        count: Int,
        hasOpen: Bool,
        hasFullOnly: Bool
    ) {

        currentCount = count
        currentHasOpen = hasOpen
        currentHasFullOnly = hasFullOnly

        applyStyle()
    }

    // Applique le style du cluster
    private func applyStyle() {

        bubbleView.layer.shadowOpacity = 0
        bubbleView.layer.shadowRadius = 0
        bubbleView.layer.shadowColor = nil

        // Ouvert
        if currentHasOpen {

            bubbleView.backgroundColor =
                UIColor(AppColors.primary)

            bubbleView.layer.borderWidth = 1.5

            bubbleView.layer.borderColor =
                UIColor.white.cgColor

            countLabel.textColor = .white

            bubbleView.layer.shadowColor =
                UIColor(AppColors.primary).cgColor

            bubbleView.layer.shadowOpacity = 0.28

            bubbleView.layer.shadowRadius = 10

            bubbleView.layer.shadowOffset = .zero
        }

        //Pleine
        else if currentHasFullOnly {

            bubbleView.backgroundColor =
                UIColor(AppColors.action)

            bubbleView.layer.borderWidth = 1.5

            bubbleView.layer.borderColor =
                UIColor.white.cgColor

            countLabel.textColor = .white

            bubbleView.layer.shadowColor =
                UIColor(AppColors.action).cgColor

            bubbleView.layer.shadowOpacity = 0.22

            bubbleView.layer.shadowRadius = 8

            bubbleView.layer.shadowOffset = .zero
        }

        // Vide
        else {

            bubbleView.backgroundColor = .white

            bubbleView.layer.borderWidth = 1.2

            bubbleView.layer.borderColor =
                UIColor(AppColors.primary).cgColor

            countLabel.textColor =
                UIColor(AppColors.primary)

            bubbleView.layer.shadowColor =
                UIColor.black.cgColor

            bubbleView.layer.shadowOpacity = 0.08

            bubbleView.layer.shadowRadius = 6

            bubbleView.layer.shadowOffset =
                CGSize(width: 0, height: 3)
        }

        // Affiche le nombre
        countLabel.text =
            currentCount > 99
            ? "99+"
            : "\(currentCount)"
    }
}
