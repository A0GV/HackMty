import SwiftUI

struct Login: View {
    @State private var username = ""
    @State private var password = ""

    private let antBrown = CategoryColors.principal

    var body: some View {
        VStack(spacing: 5) { // Espacio general entre secciones = 30
            Spacer()

            // Logo (mismo tamaño)
            Image("Ant killer")
                .resizable()
                .scaledToFit()
                .frame(width: 244)
                .padding(.bottom, -20)
                
            
            // Imagen secundaria (mismo tamaño)
            Image("notant")
                .resizable()
                .scaledToFit()
                .frame(width: 200)

            // Saludo
            Text("Hi, there!")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(antBrown)
                .padding(.bottom)
            

            // Campos de texto
            VStack(spacing: 25) {
                TextField("User", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .padding(.horizontal, 4)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 20)

            // Botón
            Button(action: {
                print("Sign in tapped:", username, password)
            }) {
                Text("Sign in")
                    
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(antBrown)
                    .cornerRadius(10)
            }
            .padding(.top, 25)
            .padding(.horizontal, 40)

            // Links pequeños
            VStack(spacing: 8 ) {
                Button("Forgot your password?") { /* acción */ }
                    .foregroundColor(antBrown)

                HStack {
                    Text("Want to start your ant farm?")
                    Button("Register") { /* acción */ }
                        .fontWeight(.bold)
                }
                .foregroundColor(antBrown)
            }
            .padding(.top, 15)
            .font(.system(size: 16))

            Spacer()
        }
        .padding(.horizontal, 50)
        .padding(.vertical, 20)
        .frame(width: 414, height: 874, alignment: .center)
        .background(Color.white)
        .cornerRadius(50)
        .background(Color(.sRGB, white: 0.98, opacity: 1.0).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    Login()
}
