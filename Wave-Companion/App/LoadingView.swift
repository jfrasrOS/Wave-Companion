import SwiftUI

struct LoadingView: View {
    
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var shineMove: CGFloat = -1
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ZStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .animation(.easeOut(duration: 0.6), value: logoScale)
                    .animation(.easeOut(duration: 0.6), value: logoOpacity)
                
                // Shine
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0), .white.opacity(0.5), .white.opacity(0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 140)
                    .rotationEffect(.degrees(30))
                    .offset(x: shineMove * 250)
                    .mask(
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140)
                    ) 
                    .blur(radius: 8)
                    .animation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: false), value: shineMove)
            }
        }
        .onAppear {
            logoOpacity = 1
            logoScale = 1
            shineMove = 1
        }
    }
}

