import SwiftUI

struct RegistrationBoardView: View {

    @EnvironmentObject var vm: RegistrationViewModel

    let boardTypes = ["Shortboard", "Fish", "Mid-Lenght", "Longboard", "Softboard"]
    let allBoardSizes = [
        "5'2\"", "5'4\"", "5'6\"", "5'8\"", "5'10\"",
        "6'0\"", "6'2\"", "6'4\"", "6'6\"", "6'8\"",
        "7'0\"", "7'2\"", "7'4\"", "7'6\"", "7'8\"",
        "8'0\"", "8'2\"", "8'4\"", "8'6\"", "8'8\"",
        "9'0\"", "9'2\"", "9'4\"", "9'6\"", "9'8\"",
        "10'0\"", "10'2\"", "10'4\"", "10'6\"", "10'8\"", "11'0\""
    ]
    let boardColors: [(String, Color)] = [
        ("Blanc", .white),
        ("Bleu", .blue),
        ("Rouge", .red),
        ("Noir", .black)
    ]

    var body: some View {
           VStack(spacing: 24) {

               //Choix du type de planche
               VStack(alignment: .leading, spacing: 12) {
                   Text("Type de planche")
                       .font(.headline)

                   HStack(spacing: 12) {
                       ForEach(boardTypes, id: \.self) { type in
                           Text(type)
                               .font(.subheadline.bold())
                               .padding()
                               .frame(maxWidth: .infinity)
                               // Change la couleur si sélectionné
                               .background(vm.data.boardType == type ? Color.blue : Color.white)
                               .foregroundColor(vm.data.boardType == type ? .white : .primary)
                               .overlay(RoundedRectangle(cornerRadius: 12)
                                   .stroke(Color.blue, lineWidth: 1))
                               .cornerRadius(12)
                               // Sauvegarde le type choisi
                               .onTapGesture {
                                   vm.data.boardType = type
                               }
                       }
                   }
               }

               //Choix de la taille
               VStack(alignment: .leading, spacing: 12) {
                   Text("Taille")
                       .font(.headline)
                   // PIcker pour selectioner la taille
                   Picker("Taille", selection: $vm.data.boardSize) {
                       ForEach(allBoardSizes, id: \.self) { size in
                           Text(size).tag(size)
                       }
                   }
                   .pickerStyle(.wheel)
               }

               //Choix de la couleur
               VStack(alignment: .leading, spacing: 12) {
                   Text("Couleur")
                       .font(.headline)

                   HStack(spacing: 20) {
                       ForEach(boardColors, id: \.0) { name, color in
                           Circle()
                               .fill(color)
                               .frame(width: 36, height: 36)
                               // Bordure bleue si la couleur est sélectionnée
                               .overlay(
                                   Circle()
                                       .stroke(vm.data.boardColor == name ? Color.blue : Color.clear, lineWidth: 3)
                               )
                               // Sauvegarde la couleur choisie
                               .onTapGesture {
                                   vm.data.boardColor = name
                               }
                       }
                   }
               }

               Spacer()

               //Validation
               Button {
                   print("""
                       Type   : \(vm.data.boardType)
                       Taille : \(vm.data.boardSize)
                       Couleur: \(vm.data.boardColor)
                       """)
                   vm.next(.spots)
                   
               } label: {
                   Text("Continuer")
                       .foregroundColor(.white)
                       .font(.headline)
                       .frame(maxWidth: .infinity)
                       .padding()
                       .background(isFormValid ? Color.blue : Color.gray)
                       .cornerRadius(12)
               }
               .disabled(!isFormValid)

           }
           .padding()
           .navigationTitle("Planche")
           .background(Color(.systemGroupedBackground))
       }

       // Vérifie que tous les champs sont remplis
       private var isFormValid: Bool {
           !vm.data.boardType.isEmpty &&
           !vm.data.boardSize.isEmpty &&
           !vm.data.boardColor.isEmpty
       }
   }


