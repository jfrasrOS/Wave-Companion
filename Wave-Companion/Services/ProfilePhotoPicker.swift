import SwiftUI
import PhotosUI


struct ProfilePhotoPicker: View {
    @ObservedObject var vm: RegistrationViewModel
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            // Si elle existe, on l'affiche
            if let uiImage = vm.profileUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 2))
            } else {
                // Sinon cercle vide
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(Text("Ajouter une photo").font(.caption).foregroundColor(.gray))
            }
        }
        // Mise à jour quand User choisit une nouvelle photo
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                await vm.updateProfileImage(from: newValue)
            }
        }
    }
}

