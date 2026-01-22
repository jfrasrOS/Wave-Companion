import SwiftUI
import Combine

struct AuthChoiceView: View {
    @EnvironmentObject var vm: RegistrationViewModel

    struct Slide: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let imageName: String
    }

    let slides: [Slide] = [
        Slide(title: "Surfez, rencontrez, partagez",
              description: "Créez ou rejoignez des sessions et vivez le surf autrement, ensemble.",
              imageName: "surf_hero"),
        Slide(title: "Progressez à votre rythme",
              description: "Atteignez vos objectifs et avancez étape par étape, vague après vague.",
              imageName: "surf_progression"),
        Slide(title: "Vos amis, toujours à portée de main",
              description: "Suivez leurs sessions et restez connectés, même à distance.",
              imageName: "surf_spots")
    ]

    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack(path: $vm.path) {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack {
                    // Carousel
                    TabView(selection: $currentIndex) {
                        ForEach(slides.indices, id: \.self) { index in
                            VStack(spacing: 20) {
                                Image(slides[index].imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300)
                                    .cornerRadius(20)
                                    .shadow(radius: 5)

                                Text(slides[index].title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                Text(slides[index].description)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 450)
                    .onReceive(timer) { _ in
                        withAnimation {
                            currentIndex = (currentIndex + 1) % slides.count
                        }
                    }

                    HStack(spacing: 8) {
                        ForEach(slides.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color(AppColors.primary) : Color.gray.opacity(0.3))
                                .frame(width: 7, height: 7)
                        }
                    }
                    .padding(.top, 8)

                    Spacer()

                    // Boutons
                    VStack(spacing: 15) {
                        Button {
                            vm.next(.signupMethod)
                        } label: {
                            Text("S’inscrire")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .cornerRadius(25)
                        }

                        NavigationLink {
                            LoginView()
                                .environmentObject(vm)
                        } label: {
                            Text("Se connecter")
                                .font(.headline)
                                .foregroundColor(AppColors.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color(AppColors.primary), lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .navigationDestination(for: RegistrationStep.self) { step in
                    switch step {
                    case .signupMethod:
                        SignUpMethodView().environmentObject(vm)
                    case .profile:
                        RegistrationProfileView().environmentObject(vm)
                    case .surfLevel:
                        RegistrationSurfLevelView().environmentObject(vm)
                    case .board:
                        RegistrationBoardView().environmentObject(vm)
                    case .spots:
                        RegistrationFavoritesSpotsView().environmentObject(vm)
                    }
                }
            }
        }
    }
}


#Preview {
    AuthChoiceView()
        .environmentObject(RegistrationViewModel())
        .environmentObject(SessionManager())
}


