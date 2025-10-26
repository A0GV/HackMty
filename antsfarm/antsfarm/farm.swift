//
//  farm.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct farm: View {
    @EnvironmentObject var goalData: GoalData // Global
    
    @State private var showSlotMachine = false // Toggle between hide and show machine
    @State private var leaves:Int = 0 // API Get player num of leaves
    @State private var numAnts:Int = 10 // API Get DB num of ants
    @State public var id_usuario:Int = 1 // Temp id usuario fijo
    
    // Number of ants from db
    
    
    // Get user number of leaves for user
    func getNumLeaves() {
        guard let url = URL(string: "http://localhost:5001/api/farm/\(id_usuario)") else {
            print("El endpoint no está disponible")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error en la llamada: \(error.localizedDescription)")
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Respuesta no válida del servidor")
                return
            }
            
            // Check status code
            if httpResponse.statusCode != 200 {
                print("Código de error del API: \(httpResponse.statusCode)")
                return
            }
            
            // Check if data exists
            guard let data = data else {
                print("No se recibieron datos")
                return
            }
            
            // Decode JSON
            do {
                let decoder = JSONDecoder()
                let farmResponse = try decoder.decode(FarmResponse.self, from: data)
                
                // Update state on main thread
                DispatchQueue.main.async {
                    self.leaves = farmResponse.farm.leaves_count
                    //self.numAnts = farmResponse.farm.ants_count
                    print("Leaves: \(self.leaves)")
                }
            } catch {
                print("Error al decodificar JSON: \(error)")
                // Print raw data for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Datos recibidos: \(jsonString)")
                }
            }
        }
        
        task.resume()
    }
    
    // Update leaves based on how much user sends
    func updateLeaves(changeAmt: Int) {
        guard let url = URL(string: "http://localhost:5001/api/farm/\(id_usuario)/leaves") else {
            print("El endpoint no está disponible")
            return
        }
        
        // Create the request body
        let requestBody = UpdateLeavesRequest(leaves: changeAmt)
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // or "PUT" depending on your API
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the body to JSON
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Error al codificar el body: \(error)")
            return
        }
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error en la llamada: \(error.localizedDescription)")
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Respuesta no válida del servidor")
                return
            }
            
            // Check status code
            if httpResponse.statusCode != 200 {
                print("Código de error del API: \(httpResponse.statusCode)")
                return
            }
            
            // Check if data exists
            guard let data = data else {
                print("No se recibieron datos")
                return
            }
            
            // Decode JSON response
            do {
                let decoder = JSONDecoder()
                let farmResponse = try decoder.decode(FarmResponse.self, from: data)
                
                // Update state on main thread
                DispatchQueue.main.async {
                    self.leaves = farmResponse.farm.leaves_count
                    print("Leaves updated: \(self.leaves)")
                }
            } catch {
                print("Error al decodificar JSON: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Datos recibidos: \(jsonString)")
                }
            }
        }
        
        task.resume()
    }
    
    
    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    // Fondo
                    VStack(spacing: 0) {
                        Image("fonfo")
                            .resizable()
                            .scaledToFill()
                            .frame(height: geometry.size.height / 2)
                        
                        Image("fonfo")
                            .resizable()
                            .scaledToFill()
                            .frame(height: geometry.size.height / 2)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(edges: [.top, .leading, .trailing])
                    
                    // Hormigas rebotando
                    BouncingAnt(
                        antImage: "notant",
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height
                    )
                    
                    // UI encima
                    VStack(alignment: .trailing, spacing: 20) {
                        // Item counters
                        HStack {
                            Spacer()
                            // Farm text
                            /*
                            Text("My farm")
                                .font(.system(size: 30))
                                .bold()
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(10)
                                .foregroundStyle(CategoryColors.principal)
                             */
                                                        
                            // Number of ants
                            HStack(alignment: .center) {
                                Image("notant")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                Text("\(numAnts)")
                                    .font(.system(size: 30))
                                    .bold()
                                    .foregroundStyle(CategoryColors.principal)
                            }
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.trailing, 10) // More space between elements
                                                        
                            // Show leaves
                            HStack(alignment: .center) {
                                Image("hoja")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                Text("\(leaves)")
                                    .font(.system(size: 30))
                                    .bold()
                                    .foregroundStyle(CategoryColors.principal)
                            }
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(10)
                            
                            //Spacer()
                        }
                        
                        
                        // Button to open and close slot machine
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSlotMachine.toggle()
                            }
                        }) {
                            Text(showSlotMachine ? "Close Slot Machine" : "Play Slot Machine")
                                .font(.system(size: 25))
                                .bold()
                                .foregroundStyle(Color.white)
                        }
                        .padding(8)
                        .background(showSlotMachine ? CategoryColors.secondaryRed : CategoryColors.principal)
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 80)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    
                    // Slot Machine Overlay
                    if showSlotMachine {
                        Color.black.opacity(0.1) // Semi-transparent backdrop
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSlotMachine = false
                                }
                            }
                        
                        // Pass the binding and the update function
                        SlotMachineView(
                            numLeaves: $leaves,
                            onLeavesChange: { amount in
                                updateLeaves(changeAmt: amount)
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                    }
                }
                .onAppear() {
                    getNumLeaves()
                }
            }
            .ignoresSafeArea(edges: [.top, .leading, .trailing])
        }
}

#Preview {
    farm().environmentObject(GoalData())
}
