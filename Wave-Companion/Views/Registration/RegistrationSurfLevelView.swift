import SwiftUI

struct RegistrationSurfLevelView: View {

    @EnvironmentObject var vm: RegistrationViewModel
    let levels = SurfLevelService.loadLevels()

    // Grouper les niveaux par catégorie directement
    private var groupedLevels: [String: [SurfLevelModel]] {
        Dictionary(grouping: levels, by: { $0.category })
    }

    // Ordre des catégories pour affichage
    private let categories = ["Débutant", "Intermédiaire", "Expert"]

    var body: some View {
        VStack(spacing: 20) {
            
            Text("Sélectionne ton niveau de surf")
                .font(.title2.bold())
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Parcours des catégories
                    ForEach(categories, id: \.self) { category in
                        if let categoryLevels = groupedLevels[category] {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category)
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(categoryLevels) { level in
                                            VStack(spacing: 8) {
                                                Text(level.name)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(.primary)
                                                
                                                // Résumé compétences (2 max)
                                                ForEach(level.skills.prefix(2), id: \.self) { skill in
                                                    Text("• \(skill)")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                // Checkmark si sélectionné
                                                if vm.data.surfLevel?.id == level.id {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.blue)
                                                        .font(.title3)
                                                }
                                            }
                                            .padding()
                                            .frame(width: 180)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(vm.data.surfLevel?.id == level.id ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                            )
                                            .onTapGesture {
                                                vm.data.surfLevel = level
                                                print("Niveau sélectionné :", level.name)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }

            Spacer()
            
            // Bouton Continuer
            Button {
                guard let selectedLevel = vm.data.surfLevel else { return }
                print("Niveau sélectionné :", selectedLevel.name)
                print("ID :", selectedLevel.id)
                print("Compétences :", selectedLevel.skills.joined(separator: ", "))
                
                vm.next(.board)
            } label: {
                Text("Continuer")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.data.surfLevel == nil ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(vm.data.surfLevel == nil)
            .padding(.horizontal)
            .padding(.bottom)
            
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Niveau de surf")
    }
}

