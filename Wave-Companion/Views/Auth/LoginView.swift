import SwiftUI

struct LoginView: View {

    @StateObject private var loginVM = LoginViewModel()

    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var registrationVM: RegistrationViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 28) {

                

                Text("Se connecter")
                    .font(.title.bold())
                Spacer()
                // Social Sign-In
                VStack(spacing: 16) {
                    Button {
                        // Apple Sign-In (plus tard)
                    } label: {
                        HStack {
                            Image(systemName: "applelogo")
                            Text("Continuer avec Apple")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(14)
                    }

                    // Google
                    Button {
                        Task { await loginVM.loginWithGoogle(
                            session: session,
                            registrationVM: registrationVM
                        ) }
                    } label: {
                        HStack {
                            Image("google_icon")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Continuer avec Google")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.4))
                        )
                    }
                }
                .padding(.horizontal)
               
                // Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("ou")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }

                // Email / Password
                VStack(spacing: 12) {

                    TextField("Adresse email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )

                    SecureField("Mot de passe", text: $password)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )

                    Button {
                        Task {
                            await loginVM.loginWithEmailPassword(
                                email: email,
                                password: password,
                                session: session,
                                registrationVM: registrationVM
                            )
                        }
                    } label: {
                        Text("Se connecter")
                            .font(.headline)
                            .foregroundColor(email.isEmpty || password.isEmpty ? AppColors.primary : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                email.isEmpty || password.isEmpty
                                    ? Color.white
                                    : AppColors.action
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(email.isEmpty || password.isEmpty ? AppColors.primary : Color.clear, lineWidth: 2)
                            )
                            .cornerRadius(25)
                            .padding(.top)
                }
                    .disabled(email.isEmpty || password.isEmpty)
                }

                // Erreur
                if let error = loginVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
        }
        .overlay {
            if loginVM.isLoading {
                ProgressView()
                    .scaleEffect(1.3)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(RegistrationViewModel())
        .environmentObject(SessionManager())
}

