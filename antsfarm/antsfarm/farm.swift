//
//  farm.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct farm: View {
    var body: some View {
        //Fondo
        ZStack {
            GeometryReader { geometry in
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
            }
            .ignoresSafeArea(edges: [.top, .leading, .trailing])
            
            VStack {
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
                    }.padding(5).background(CategoryColors.principal)
                        .cornerRadius(10)
                    
                    Spacer()
                }
                .padding(30)
                .padding(.top, 20)
                
                Spacer()
            }

        }
    }
}
#Preview {
    farm()
}
