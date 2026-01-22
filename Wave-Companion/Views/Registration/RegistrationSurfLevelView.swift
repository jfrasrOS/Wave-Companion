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
    
    @State private var selectedCategory: String? = nil
    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
          
        
              

            VStack(spacing: 0) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ton niveau de surf ?")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Pour que tu puisses rejoindre les bonnes sessions, rencontrer des surfeurs comme toi et suivre tes progrès.")
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }

                
                // Niveau catégorie
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            withAnimation(.easeInOut) {
                                selectedCategory = category
                            }
                        } label: {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(selectedCategory == category ? .bold : .regular)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 14)
                                .background(
                                    ZStack {
                                        if selectedCategory == category {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "#EF5B38"))
                                                .matchedGeometryEffect(id: "highlight", in: animationNamespace)
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke( AppColors.primary, lineWidth: 2)
                                        }
                                    }
                                )
                                .foregroundColor(selectedCategory == category ? .white : AppColors.primary)
                        }
                    }
                }
                .padding()
                
                

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Filtrer selon la catégorie sélectionnée
                        ForEach(selectedCategory != nil ? [selectedCategory!] : categories, id: \.self) { category in
                            if let categoryLevels = groupedLevels[category] {
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(categoryLevels) { level in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(level.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            
                                            
                                            ForEach(level.skills, id: \.self) { skill in
                                                HStack(alignment: .top) {
                                                    Text("•")
                                                        .foregroundColor(Color(hex: "#EF5B38"))
                                                    Text(skill)
                                                        .foregroundColor(.primary)
                                                }
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(vm.data.surfLevel?.id == level.id ? Color(hex: "#EF5B38") : Color.gray.opacity(0.3), lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            vm.data.surfLevel = level
                                        }
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                

                Spacer()
                
              
                Button {
                    guard vm.data.surfLevel != nil else { return }
                    vm.next(.board)
                } label: {
                    Text("Continuer")
                        .foregroundColor(vm.data.surfLevel == nil ? AppColors.primary : Color.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.data.surfLevel == nil ? Color.white : AppColors.action )
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(vm.data.surfLevel == nil ? AppColors.primary : Color.clear, lineWidth: 2)
                        )
                }
                .disabled(vm.data.surfLevel == nil)
                .padding()
                .padding(.bottom)
            }
        }
        .onAppear {
            //par défaut sur Débutant si rien n'est sélectionné
            if selectedCategory == nil { selectedCategory = "Débutant" }
        }
    }
}

#Preview {
    RegistrationSurfLevelView()
        .environmentObject(RegistrationViewModel())
}

