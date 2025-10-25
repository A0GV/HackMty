//
//  CatGoal.swift
//  antsfarm
//
//  Created by Monica Guzman on 25/10/25.
//

import SwiftUI

struct CatGoal: View {
    var body: some View {
        HStack {
            // Small square
            Rectangle()
            .foregroundColor(.clear)
            .frame(width: 25, height: 30)
            .background(CategoryColors.food)
            .cornerRadius(10)
            
            // Category name
            Text("Food")
            
            // Category amount
        }
        .padding(.top, 15)
    }
}

#Preview {
    CatGoal()
}
