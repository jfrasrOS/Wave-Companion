import SwiftUI

struct LoadingView: View {
    
    // Animation du logo
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    
    // Animation du shine
    @State private var shineMove: CGFloat = -1
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Fond
            
            // Logo avec shine
            ZStack {
                // Logo principal
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .animation(.easeOut(duration: 0.6), value: logoScale)
                    .animation(.easeOut(duration: 0.6), value: logoOpacity)
                
                // Shine fluide
                Image("logo") // même logo en overlay pour le masque
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .overlay(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0),
                                        .white.opacity(0.5),
                                        .white.opacity(0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: shineMove * 250)
                            .blendMode(.plusLighter)
                            .blur(radius: 8)
                           
                    )
            }
            .frame(width: 140)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            // Logo animation
            logoOpacity = 1
            logoScale = 1
            
            // Commence immédiatement
            shineMove = -1 // reset
            withAnimation(.easeInOut(duration: 3)) {
                shineMove = 1
            }
        }
    }}

#Preview {
    LoadingView()
}

