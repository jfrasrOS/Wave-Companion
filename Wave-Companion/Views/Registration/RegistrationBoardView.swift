import SwiftUI

struct RegistrationBoardView: View {

    @EnvironmentObject var vm: RegistrationViewModel

    private let boardTypes = ["Shortboard", "Fish", "Mid-Length", "Longboard", "Softboard"]

    // Tailles possibles
    private let boardSizes = [
        "5'0\"", "5'2\"", "5'4\"", "5'6\"", "5'8\"", "5'10\"", "6'0\"", "6'2\"", "6'4\"",
        "6'6\"", "6'8\"", "7'0\"", "7'2\"", "7'4\"", "7'6\"", "8'0\"", "8'6\"", "9'0\"", "9'6\"", "10'0\""
    ]

    // Couleur (HSB)
    @State private var hue: Double = 0.0
    @State private var saturation: Double = 1.0
    @State private var brightness: Double = 0.5

    var body: some View {
        RegistrationStepContainer(
            title: "C’est quoi ta planche ?",
            subtitle: "Type, taille et couleur",
            currentStep: 2,
            totalSteps: 4,
            isActionEnabled: isFormValid,
            onBack: { vm.back() },
            onAction: { vm.next(.spots) }
        ) {

            // ScrollView verticale pour centrer le contenu
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {

                    // Zone couleur + type + taille
                    BoardSelectorView(
                        boardTypes: boardTypes,
                        boardSizes: boardSizes,
                        hue: $hue,
                        saturation: $saturation,
                        brightness: $brightness
                    )
                    .environmentObject(vm)

                    Spacer(minLength: 20)
                }
                .frame(maxHeight: .infinity)
            }
            .onAppear {
                // initialise le type de planche si vide
                if vm.data.boardType.isEmpty {
                    vm.data.boardType = boardTypes.first!
                }
            }
        }
    }

    // Validation formulaire
    private var isFormValid: Bool {
        !vm.data.boardType.isEmpty && !vm.data.boardSize.isEmpty
    }
}

#Preview {
    RegistrationBoardView()
        .environmentObject(RegistrationViewModel())
}

