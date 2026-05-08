import Foundation
import SwiftUI
import MapKit

struct MapSnapshotImageView: View {
    
    let latitude: Double
    let longitude: Double
    
    let width: CGFloat
    let height: CGFloat
    
    @State private var image: UIImage?
    
    @Environment(\.displayScale) private var displayScale
    
    var body: some View {
        
        ZStack {
            
            Color.gray.opacity(0.15)
            
            if let image {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .saturation(0.92)
                    .contrast(1.03)
                    .transition(.opacity)
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .onAppear {
            loadSnapshot()
        }
    }
}


extension MapSnapshotImageView {
    
    private func loadSnapshot() {
        
        let options = MKMapSnapshotter.Options()
        
        // Satellite
        options.mapType = .satelliteFlyover
        
        options.size = CGSize(
            width: width * displayScale,
            height: height * displayScale
        )
        
        options.scale = displayScale
        
        // CAMERA 3D
        let camera = MKMapCamera()
        
        camera.centerCoordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
        
        // hauteur caméra
        camera.altitude = 1000
        
        // inclinaison
        camera.pitch = 45
        
        // rotation
        camera.heading = 0
        
        options.camera = camera
        
        MKMapSnapshotter(options: options)
            .start { snapshot, error in
                
                guard let snapshot else { return }
                
                DispatchQueue.main.async {
                    self.image = snapshot.image
                }
            }
    }
}
