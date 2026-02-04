//
//  BoardSelectorView.swift
//  Wave-Companion
//
//  Created by John on 04/02/2026.
//

import SwiftUI


// Composant réutilisable pour choisir : type, couleur et taille de planche
struct BoardSelectorView: View {

    @EnvironmentObject var vm: RegistrationViewModel

    // Liste des types de planches
    let boardTypes: [String]

    // Liste des tailles de planches
    let boardSizes: [String]

    // Couleur HSB
    @Binding var hue: Double
    @Binding var saturation: Double
    @Binding var brightness: Double

    var body: some View {
        VStack(spacing: 32) {

            Spacer(minLength: 20)

            //Zone couleur + planche
            VStack(spacing: 20) {

                ZStack {
                    // Roue des couleurs
                    ColorWheel(hue: $hue, saturation: $saturation)
                        .frame(width: 300, height: 300)

                    // Carrousel des types de planche
                    BoardCarousel(
                        boardTypes: boardTypes,
                        selectedType: $vm.data.boardType,
                        color: currentColor
                    )
                    .frame(width: 240, height: 280)
                }

                // Nuanceur horizontal
                HorizontalBrightnessSlider(
                    brightness: $brightness,
                    hue: hue,
                    saturation: saturation
                )
                .frame(height: 18)
                .padding(.horizontal, 48)
            }

            //Carrousel des tailles
            BoardSizeCarousel(
                sizes: boardSizes,
                selectedSize: $vm.data.boardSize
            )
            .frame(height: 80)

            Spacer(minLength: 20)
        }
        .onChange(of: currentColor) {
            vm.data.boardColor = currentColor.toHex()
        }
    }

    // Couleur actuelle selon HSB et brightness
    private var currentColor: Color {
        if brightness < 0.5 {
            // Noir vers couleur
            let localBrightness = brightness / 0.5
            return Color(hue: hue, saturation: saturation, brightness: localBrightness)
        } else {
            // Couleur vers blanc
            let localSaturation = saturation * (1 - (brightness - 0.5) / 0.5)
            return Color(hue: hue, saturation: localSaturation, brightness: 1)
        }
    }
}

// -----------------------------
// ColorWheel
// -----------------------------
struct ColorWheel: View {

    @Binding var hue: Double
    @Binding var saturation: Double

    private let lineWidth: CGFloat = 6
    private let knobSize: CGFloat = 26

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Cercle de couleurs
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(
                                colors: stride(from: 0.0, to: 1.0, by: 0.01).map { Color(hue: $0, saturation: 1, brightness: 1) }
                            ),
                            center: .center
                        ),
                        lineWidth: lineWidth
                    )

                // Knob pour sélectionner
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: knobSize, height: knobSize)
                    .position(knobPosition(in: geo.size))
                    .shadow(radius: 3)
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateHue(from: value.location, in: geo.size)
                    }
            )
        }
    }

    private func knobPosition(in size: CGSize) -> CGPoint {
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let radius = (size.width - lineWidth)/2
        return CGPoint(
            x: center.x + cos(hue * 2 * .pi) * radius,
            y: center.y + sin(hue * 2 * .pi) * radius
        )
    }

    private func updateHue(from point: CGPoint, in size: CGSize) {
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let angle = atan2(point.y - center.y, point.x - center.x)
        var value = angle / (2 * .pi)
        if value < 0 { value += 1 }
        hue = value
    }
}

// -----------------------------
// HorizontalBrightnessSlider
// -----------------------------
struct HorizontalBrightnessSlider: View {

    @Binding var brightness: Double
    let hue: Double
    let saturation: Double

    private let trackHeight: CGFloat = 6
    private let knobSize: CGFloat = 26

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Gradient horizontal
                LinearGradient(
                    colors: [.black, Color(hue: hue, saturation: saturation, brightness: 1), .white],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: trackHeight)
                .cornerRadius(trackHeight/2)

                // Knob
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: knobSize, height: knobSize)
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    .position(x: brightness * geo.size.width, y: geo.size.height/2)
                    .shadow(radius: 4)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                brightness = min(max(value.location.x / geo.size.width, 0), 1)
                            }
                    )
            }
        }
    }
}

// -----------------------------
// BoardCarousel
// -----------------------------
struct BoardCarousel: View {

    @EnvironmentObject var vm: RegistrationViewModel
    let boardTypes: [String]
    @Binding var selectedType: String
    let color: Color

    let boardScales: [String: CGFloat] = [
        "Shortboard": 0.7,
        "Fish": 0.65,
        "Mid-Length": 0.85,
        "Softboard": 0.9,
        "Longboard": 1.0
    ]

    var body: some View {
        VStack(spacing: 10) {

            TabView(selection: $selectedType) {
                ForEach(boardTypes, id: \.self) { type in
                    ZStack(alignment: .bottom) {
                        Image(type.lowercased())
                            .resizable()
                            .scaledToFit()
                        Image(type.lowercased())
                            .resizable()
                            .scaledToFit()
                            .colorMultiply(color)
                    }
                    .scaleEffect(boardScales[type] ?? 1.0, anchor: .bottom)
                    .frame(height: 190)
                    .tag(type)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 190)

            // Dots
            HStack(spacing: 6) {
                ForEach(boardTypes, id: \.self) { type in
                    Circle()
                        .fill(type == selectedType ? AppColors.action : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }

            // Nom + taille sélectionnée
            VStack(spacing: 4) {
                Text(selectedType).font(.headline.bold())
                if !vm.data.boardSize.isEmpty {
                    Text(vm.data.boardSize).font(.caption).foregroundColor(.secondary)
                }
            }
        }
    }
}

// -----------------------------
// BoardSizeCarousel
// -----------------------------
struct BoardSizeCarousel: View {

    let sizes: [String]
    @Binding var selectedSize: String
    @State private var itemPositions: [String: CGFloat] = [:]
    @State private var scrollProxy: ScrollViewProxy? = nil

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width

            ZStack {
                // Cercle central (focus)
                Circle()
                    .fill(.ultraThinMaterial) // glass effect
                    .background(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    .frame(width: 70, height: 70)
                    .position(x: screenWidth/2, y: 40)
                    .shadow(radius: 2)

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(sizes, id: \.self) { size in
                                GeometryReader { itemGeo in
                                    let midX = itemGeo.frame(in: .global).midX
                                    Color.clear
                                        .preference(key: ItemMidXKey.self, value: [size: midX])

                                    Text(size)
                                        .font(.title3.weight(.bold))
                                        .scaleEffect(isFocused(midX, screenWidth: screenWidth) ? 1.4 : scale(for: midX, screenWidth: screenWidth))
                                        .opacity(opacity(for: midX, screenWidth: screenWidth))
                                        .foregroundColor(isFocused(midX, screenWidth: screenWidth) ? AppColors.primary : .primary.opacity(0.4))
                                        .frame(width: 60, height: 60)
                                }
                                .frame(width: 60, height: 60)
                            }
                        }
                        .padding(.horizontal, screenWidth/2 - 30)
                    }
                    .onAppear { scrollProxy = proxy; scrollToSelected(screenWidth: screenWidth) }
                    .onPreferenceChange(ItemMidXKey.self) { values in
                        itemPositions = values
                        updateSelectedSize(screenWidth: screenWidth)
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { _ in snapToCenter(screenWidth: screenWidth, proxy: proxy) }
                    )
                }
            }
        }
        .frame(height: 80)
    }

    // Scale & opacity
    private func scale(for midX: CGFloat, screenWidth: CGFloat) -> CGFloat {
        let distance = abs(midX - screenWidth/2)
        return max(0.7, 1 - (distance / screenWidth))
    }

    private func opacity(for midX: CGFloat, screenWidth: CGFloat) -> Double {
        let distance = abs(midX - screenWidth/2)
        return max(0.5, 1 - (distance / (screenWidth * 0.8)))
    }

    private func isFocused(_ midX: CGFloat, screenWidth: CGFloat) -> Bool {
        abs(midX - screenWidth/2) < 30
    }

    private func updateSelectedSize(screenWidth: CGFloat) {
        guard !itemPositions.isEmpty else { return }
        let closest = itemPositions.min { abs($0.value - screenWidth/2) < abs($1.value - screenWidth/2) }
        if let newSize = closest?.key, newSize != selectedSize {
            selectedSize = newSize
        }
    }

    private func snapToCenter(screenWidth: CGFloat, proxy: ScrollViewProxy) {
        guard !itemPositions.isEmpty else { return }
        let closest = itemPositions.min { abs($0.value - screenWidth/2) < abs($1.value - screenWidth/2) }
        if let newSize = closest?.key {
            withAnimation(.easeOut) { proxy.scrollTo(newSize, anchor: .center) }
        }
    }

    private func scrollToSelected(screenWidth: CGFloat) {
        DispatchQueue.main.async {
            scrollProxy?.scrollTo(selectedSize, anchor: .center)
        }
    }
}

// -----------------------------
// PreferenceKey pour récupérer les positions
// -----------------------------
struct ItemMidXKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String : CGFloat], nextValue: () -> [String : CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}

// -----------------------------
// Extension couleur hex
// -----------------------------
extension Color {
    func toHex() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
}

