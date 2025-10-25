//
//  Login.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct Login: View {
    @State private var username = ""
       @State private var password = ""

       // Color marrón usado en la imagen (ajusta si quieres)
       private let antBrown = Color(red: 97/255, green: 48/255, blue: 43/255)

       var body: some View {
           VStack(spacing: 24) {
               Spacer().frame(height: 28)

               // Logo (opcional)
               Image("ant_pixel")
                   .resizable()
                   .scaledToFit()
                   .frame(width: 100, height: 100)
                   .padding(.top, 4)

               // Saludo
               Text("Hi, there!")
                   .font(.system(size: 28, weight: .regular))
                   .foregroundColor(antBrown)

               // Campos de texto simples
               VStack(spacing: 16) {
                   TextField("User", text: $username)
                       .textFieldStyle(.roundedBorder)
                       .autocapitalization(.none)
                       .padding(.horizontal, 4)

                   SecureField("Password", text: $password)
                       .textFieldStyle(.roundedBorder)
                       .padding(.horizontal, 4)
               }
               .padding(.horizontal, 20)

               // Botón simple
               Button(action: {
                   // Acción de login
                   print("Sign in tapped:", username, password)
               }) {
                   Text("Sign in")
                       .foregroundColor(.white)
                       .frame(maxWidth: .infinity)
                       .frame(height: 50)
                       .background(antBrown)
                       .cornerRadius(10)
               }
               .padding(.horizontal, 40)
               .padding(.top, 8)

               // Links pequeños
               VStack(spacing: 8) {
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
               .padding(.top, 8)

               Spacer()
           }
           // Caja blanca redondeada como en tu ejemplo (fácil de ajustar)
           .padding(.horizontal, 50)
           .padding(.top, 0)
           .padding(.bottom, 20)
           .frame(width: 414, height: 874, alignment: .center)
           .background(Color.white)
           .cornerRadius(50)
           // Fondo general de la pantalla
           .background(Color(.sRGB, white: 0.98, opacity: 1.0).edgesIgnoringSafeArea(.all))
       }
   }


#Preview {
    Login()
}
