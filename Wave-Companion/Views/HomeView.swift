import SwiftUI


struct HomeView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Page Accueil")
                .font(.title.bold())
            Spacer()
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(RegistrationViewModel())
}
