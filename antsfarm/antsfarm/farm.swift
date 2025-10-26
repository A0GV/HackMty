//
//  farm.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct farm: View {
    @State private var showSlotMachine = false // Toggle between hide and show machine
    @State private var leaves:Int = 200 // API Get player num of leaves
    @State private var numAnts:Int = 10 // API Get DB num of ants
    
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
                        
                        // Make it have the num of leaves to handle internal building
                        SlotMachineView(numLeaves: $leaves)
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(1)
                    }
                }
            }
            .ignoresSafeArea(edges: [.top, .leading, .trailing])
        }
}

#Preview {
    farm().environmentObject(GoalData())
}
