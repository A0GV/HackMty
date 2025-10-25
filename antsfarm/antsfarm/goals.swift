//
//  goals.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct goals: View {
    @State public var weeklyBudget: Double = 0
    
    var body: some View {
        ScrollView {
            VStack (alignment: .center){
                Text("Goals")
                    .font(.system(size: 30))
                    .foregroundStyle(CategoryColors.principal)
                    .bold()
                    .padding([.top, .bottom], 30)
                
                Text("Weekly Budget")
                    .font(.system(size: 25))
                    .foregroundStyle(CategoryColors.secondaryRed)
                    .bold()
                    .padding([.top, .bottom], 10)
                
                // Budget box
                HStack {
                    // Change to get from database the total plan
                    Text("$\(weeklyBudget, specifier: "%.2f") MXN")
                        .foregroundStyle(CategoryColors.secondaryRed)
                }
                .frame(width: 314, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.41, green: 0.23, blue: 0.2), lineWidth: 1)
                )
                
                // Types of expenses
                VStack {
                    Text("Category")
                        .font(.system(size: 25))
                        .foregroundStyle(CategoryColors.secondaryRed)
                        .bold()
                    
                    // Cat: Food
                    
                }
                .padding(.top, 40)
            }
        }
    }
}

#Preview {
    goals()
}
