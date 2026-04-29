//
//  MapSnapshotImageView.swift
//  Wave-Companion
//
//  Created by John on 24/04/2026.
//

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
            
            Color.gray.opacity(0.2)
            
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .onAppear {
            loadSnapshot()
        }
    }
    
    private func loadSnapshot() {
        let options = MKMapSnapshotter.Options()
        
        options.mapType = .satellite
        options.size = CGSize(width: width * displayScale,
                              height: height * displayScale)
        options.scale = displayScale
        
        options.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        MKMapSnapshotter(options: options).start { snapshot, _ in
            if let snapshotImage = snapshot?.image {
                DispatchQueue.main.async {
                    self.image = snapshotImage
                }
            }
        }
    }
}
