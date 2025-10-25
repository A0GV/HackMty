//
//  CatGoal.swift
//  antsfarm
//
//  Created by Monica Guzman on 25/10/25.
//

import SwiftUI

struct CatGoal: View {
    var color: Color // Square color
    var category: String // Category title
    @Binding var amount: Double // Amount of money to spend
    
    
    var body: some View {
        HStack {
            // Small square
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 25, height: 30)
                .background(color)
                .cornerRadius(10)
            
            // Category name
            Text(category)
                .padding(.leading, 10)
                .font(.system(size: 20))
                .foregroundStyle(CategoryColors.secondaryRed)
            
            Spacer()
            
            // Category amount
            /*
            Text("$\(amount, specifier: "%.2f") MXN")
                .padding(10)
                .font(.system(size: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(CategoryColors.principal)
                )
             */
            
            // Category amount as text field
            TextField("Amount", value: $amount, format: .currency(code: "MXN"))
                .padding(10)
                .frame(width: 148) // Fixed width frame
                //.frame(minWidth: 108, maxWidth: 163)
                .font(.system(size: 20))
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: 0.5)
                        .stroke(CategoryColors.principal)
                )
                    .tint(CategoryColors.drinks) // giving it a blue color to match palette
            
        }
        .padding(.top, 5)
    }
}

#Preview {
    CatGoal(color: CategoryColors.principal, category: "Category", amount: .constant(0.00))
}
