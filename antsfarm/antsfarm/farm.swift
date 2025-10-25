//
//  farm.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct farm: View {
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
                
                // Hormigas rebotando (should be add in a diferrent way)
                BouncingAnt(
                    antImage: "notant",
                    screenWidth: geometry.size.width,
                    screenHeight: geometry.size.height
                )
                
                // UI encima
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("My farm")
                            .font(.system(size: 30))
                            .bold()
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(10)
                            .foregroundStyle(CategoryColors.principal)
                        
                        Spacer()
                        
                        HStack(alignment: .center) {
                            Image("hoja")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                            Text("15")
                                .font(.system(size: 30))
                                .bold()
                                .foregroundStyle(CategoryColors.principal)
                        }
                        .padding(5)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action:{}){
                        Text("Spin roulette")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundStyle(Color.white)
                    }
                    .padding(5)
                    .background(CategoryColors.principal)
                    .cornerRadius(10)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .ignoresSafeArea(edges: [.top, .leading, .trailing])
    }
}

#Preview {
    farm().environmentObject(GoalData())
}
