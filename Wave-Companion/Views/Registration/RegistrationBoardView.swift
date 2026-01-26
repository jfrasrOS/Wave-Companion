import SwiftUI

struct RegistrationBoardView: View {

    @EnvironmentObject var vm: RegistrationViewModel

    private let boardTypes = [
        "Shortboard", "Fish", "Mid-Length", "Longboard", "Softboard"
    ]

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

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        RegistrationStepContainer(
            title: "C’est quoi ta planche ?",
            subtitle: "Type, taille et couleur pour te reconnaître à l’eau.",
            currentStep: 2,
            totalSteps: 5,
            isActionEnabled: isFormValid,
            onAction: {
                vm.next(.spots)
            }
        ) {
            boardTypeSection
            boardSizeSection
            boardColorSection
        }
    }

 

    private var boardTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type de planche")
                .font(.headline)

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(boardTypes, id: \.self) { type in
                    SelectableChip(
                        title: type,
                        isSelected: vm.data.boardType == type
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            vm.data.boardType = type
                        }
                    }
                }
            }
        }
    }

    private var boardSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Taille")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(boardSizes, id: \.self) { size in
                        SelectableCapsule(
                            title: size,
                            isSelected: vm.data.boardSize == size
                        ) {
                            withAnimation(.easeInOut) {
                                vm.data.boardSize = size
                            }
                        }
                    }
                }
            }
        }
    }

    private var boardColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Couleur")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(boardColors, id: \.name) { item in
                        Circle()
                            .fill(item.color)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(
                                        vm.data.boardColor == item.name
                                        ? AppColors.primary
                                        : Color.clear,
                                        lineWidth: 4
                                    )
                            )
                            .scaleEffect(
                                vm.data.boardColor == item.name ? 1.1 : 1.0
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    vm.data.boardColor = item.name
                                }
                            }
                    }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !vm.data.boardType.isEmpty &&
        !vm.data.boardSize.isEmpty &&
        !vm.data.boardColor.isEmpty
    }
}

