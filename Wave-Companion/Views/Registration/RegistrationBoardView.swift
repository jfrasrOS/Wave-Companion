import SwiftUI

struct RegistrationBoardView: View {

    @EnvironmentObject var vm: RegistrationViewModel


    private let boardTypes = ["Shortboard", "Fish", "Mid-Length", "Longboard", "Softboard"]

    private let boardSizes = [
        "5'2\"", "5'4\"", "5'6\"", "5'8\"", "5'10\"",
        "6'0\"", "6'2\"", "6'4\"", "6'6\"", "6'8\"",
        "7'0\"", "7'2\"", "7'4\"", "7'6\"", "7'8\"",
        "8'0\"", "8'2\"", "8'4\"", "8'6\"", "8'8\"",
        "9'0\"", "9'2\"", "9'4\"", "9'6\"", "9'8\"",
        "10'0\"", "10'2\"", "10'4\"", "10'6\"", "10'8\"", "11'0\""
    ]

    private let boardColors: [(name: String, color: Color)] = [
        ("Blanc", .white),
        ("Crème", Color(red: 0.96, green: 0.94, blue: 0.88)),
        ("Sable", Color(red: 0.85, green: 0.80, blue: 0.70)),
        ("Bleu", .blue),
        ("Bleu marine", Color(red: 0.10, green: 0.20, blue: 0.35)),
        ("Vert", .green),
        ("Orange", .orange),
        ("Rouge", .red),
        ("Noir", .black)
    ]

    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
         
              

            ScrollView {
                VStack(spacing: 24) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ta planche")
                            .font(.largeTitle.bold())
                        Text("Choisis le type, la taille et la couleur de ta planche")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Type de planche
                    Card {
                        Text("Type de planche")
                            .font(.headline)
                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(boardTypes, id: \.self) { type in
                                Text(type)
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .background(vm.data.boardType == type ? Color.blue : Color.gray.opacity(0.15))
                                    .foregroundColor(vm.data.boardType == type ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.3)))
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            vm.data.boardType = type
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Taille
                    Card {
                        Text("Taille")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(boardSizes, id: \.self) { size in
                                    Text(size)
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(vm.data.boardSize == size ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(vm.data.boardSize == size ? .white : .primary)
                                        .clipShape(Capsule())
                                        .onTapGesture {
                                            withAnimation(.easeInOut) {
                                                vm.data.boardSize = size
                                            }
                                        }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    
                    Card {
                        Text("Couleur")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(boardColors, id: \.name) { item in
                                    ZStack {
                                        Circle()
                                            .fill(item.color)
                                            .frame(width: 44, height: 44)
                                        Circle()
                                            .stroke(vm.data.boardColor == item.name ? Color.blue : Color.clear, lineWidth: 4)
                                            .frame(width: 44, height: 44)
                                    }
                                    .scaleEffect(vm.data.boardColor == item.name ? 1.1 : 1.0)
                                    .padding(4)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            vm.data.boardColor = item.name
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                vm.next(.spots)
            } label: {
                Text("Continuer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            .disabled(!isFormValid)
        }
    }

    // Validation
    private var isFormValid: Bool {
        !vm.data.boardType.isEmpty &&
        !vm.data.boardSize.isEmpty &&
        !vm.data.boardColor.isEmpty
    }
}

// Card
struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 8, y: 4)
    }
}

#Preview {
    RegistrationBoardView()
        .environmentObject(RegistrationViewModel())
}

