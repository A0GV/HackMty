import SwiftUI

struct Login: View {
    @State private var username = ""
    @State private var password = ""

    private let antBrown = CategoryColors.principal

    var body: some View {
        VStack { // contenedor principal para centrar verticalmente
            Spacer() // empuja el contenido hacia el centro

            // Bloque central con todo el contenido visual
            VStack(spacing: 5) {
                // Logo (mismo tamaño)
                Image("Ant killer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 244)
                    .padding(.bottom, -40)
                    // eliminé el padding negativo para no desbalancear el centrado

                // Imagen secundaria (mismo tamaño)
                Image("notant")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.bottom, -40)

                // Saludo
                Text("Hi, there!")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(antBrown)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)

                // Campos de texto
                VStack(spacing: 25) {
                    TextField("User", text: $username)
                        .autocapitalization(.none)
                        .padding(.horizontal, 16)
                        .frame(height: 50) // misma altura
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(CategoryColors.principal, lineWidth: 2) // borde en color de la paleta
                        )
                        .cornerRadius(10)

                    // Password: mismo estilo que User (mismo tamaño y borde coloreado)
                    SecureField("Password", text: $password)
                        .padding(.horizontal, 16)
                        .frame(height: 50) // misma altura
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(CategoryColors.principal, lineWidth: 2) // borde en color de la paleta
                        )
                        .cornerRadius(10)
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
                .padding(.horizontal, 20)
//                .frame(maxWidth)

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
                .font(.system(size: 16))
                .padding(.top, 30)
            }
            .frame(maxWidth: .infinity) // asegurar que el bloque central ocupe todo el ancho disponible

            Spacer() // empuja el contenido hacia el centro
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
