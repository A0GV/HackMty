//
//  goals.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct goals: View {
    @State public var foodAmt: Double = 0
    @State public var drinkAmt: Double = 0
    @State public var subsAmt: Double = 0
    @State public var smallPayAmt: Double = 0
    @State public var transportAmt: Double = 0
    @State public var otherAmt: Double = 0
    
    // Calculated weekly total
    @State public var weeklyBudget: Double = 0 //foodAmt + drinkAmt + subsAmt + smallPayAmt + transportAmt + otherAmt
    
    // Calculates user total budget
    func loadBudget() {
        // Load user data from api
        
        // Calc weekly budget total
        weeklyBudget = foodAmt + drinkAmt + subsAmt + smallPayAmt + transportAmt + otherAmt
    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .center){
                Text("Budgeting Goals")
                    .font(.system(size: 30))
                    .foregroundStyle(CategoryColors.principal)
                    .bold()
                    .padding([.top, .bottom], 30)
                
                Text("Weekly Budget")
                    .font(.system(size: 25))
                    .foregroundStyle(CategoryColors.secondaryRed)
                    .bold()
                    .padding([.top, .bottom], 5)
                
                // Budget box
                HStack {
                    // Change to get from database the total plan
                    Text("$\(weeklyBudget, specifier: "%.2f") MXN")
                        .foregroundStyle(CategoryColors.secondaryRed)
                }
                .frame(width: 314, height: 34)
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
                    
                    // Forming square, label, money
                    CatGoal(color: CategoryColors.food, category: "Food", amount: $foodAmt)
                    
                    CatGoal(color: CategoryColors.drinks, category: "Drinks", amount: $drinkAmt)
                    
                    CatGoal(color: CategoryColors.subscriptions, category: "Subscriptions", amount: $subsAmt)
                    
                    CatGoal(color: CategoryColors.smallPayment, category: "Small payment", amount: $smallPayAmt)
                    
                    CatGoal(color: CategoryColors.transport, category: "Transport", amount: $transportAmt)
                    
                    CatGoal(color: CategoryColors.other, category: "Other", amount: $otherAmt)
                }
                .padding(.top, 30)
                .padding(.bottom, 15)
                .padding(.horizontal, 30)
                
                // Submit button to update goal amts, change action later on
                Button("Update Goals") {
                    print("Updated goals: food: \(foodAmt), drinks: \(drinkAmt), subscriptions: \(subsAmt), small payment: \(smallPayAmt), transport: \(transportAmt), other: \(otherAmt)")
                    // API call update in DB
                    loadBudget() // Updates user budget
                }
                .font(.system(size: 25))
                .padding(10)
                .frame(width: 314, height: 40)
                .background(CategoryColors.principal)
                .cornerRadius(10)
                .foregroundStyle(.white)
            }
            .onAppear() {
                loadBudget() // Gets user info and updates the weekly budget
            }
        }
    }
}

#Preview {
    goals()
}
