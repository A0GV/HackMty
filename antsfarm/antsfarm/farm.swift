//
//  farm.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct farm: View {
    var body: some View {
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
            
            // Your content goes here
        }
    }
}
#Preview {
    farm()
}
