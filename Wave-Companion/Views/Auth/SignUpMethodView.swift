import SwiftUI

struct SignUpMethodView: View {
    @EnvironmentObject var vm: RegistrationViewModel
    @EnvironmentObject var session: SessionManager
    @State private var email: String = ""
    @State private var password: String = ""
    
    @StateObject private var loginVM = LoginViewModel()

    var body: some View {
        ZStack {
            

            VStack(spacing: 32) {
                Text("Créer un compte")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
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
                            registrationVM: vm
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
                .padding(.horizontal)

                // Email + Password
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
                        Task { await vm.signUpWithEmailPassword(email: email, password: password) }
                    } label: {
                        Text("Continuer avec email")
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
                .padding(.horizontal)
                

                // Affichage erreur
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Spacer()

                //Login
                HStack {
                    Text("Vous avez déjà un compte ?")
                        .foregroundColor(.secondary)

                    NavigationLink {
                        LoginView()
                            .environmentObject(vm)
                    } label: {
                        Text("Se connecter")
                            .foregroundColor(Color(AppColors.primary))
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 24)
            }
            .padding()
        }
    }
}

#Preview {
    SignUpMethodView()
        .environmentObject(RegistrationViewModel())
        .environmentObject(SessionManager())
}

