//
//  goals.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct goals: View {
    @EnvironmentObject var goalData: GoalData
    
    // Calculated weekly total
//    @State public var weeklyBudget: Double = 0 //foodAmt + drinkAmt + subsAmt + smallPayAmt + transportAmt + otherAmt
    var weeklyBudget: Double {
            goalData.ExpectfoodAmt + goalData.ExpectdrinkAmt + goalData.ExpectsubsAmt + goalData.ExpectsmallPayAmt + goalData.ExpecttransportAmt + goalData.ExpectotherAmt
        }
//    // Calculates user total budget
//    func loadBudget() {
//        // Load user data from api
//        
//        // Calc weekly budget total
//        weeklyBudget = foodAmt + drinkAmt + subsAmt + smallPayAmt + transportAmt + otherAmt
//    }
    
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
                    CatGoal(color: CategoryColors.food, category: "Food", amount: $goalData.ExpectfoodAmt)
                    
                    CatGoal(color: CategoryColors.drinks, category: "Drinks", amount: $goalData.ExpectdrinkAmt)
                    
                    CatGoal(color: CategoryColors.subscriptions, category: "Subscriptions", amount: $goalData.ExpectsubsAmt)
                    
                    CatGoal(color: CategoryColors.smallPayment, category: "Small payment", amount: $goalData.ExpectsmallPayAmt)
                    
                    CatGoal(color: CategoryColors.transport, category: "Transport", amount: $goalData.ExpecttransportAmt)
                    
                    CatGoal(color: CategoryColors.other, category: "Other", amount: $goalData.ExpectotherAmt)
                }
                .padding(.top, 30)
                .padding(.bottom, 15)
                .padding(.horizontal, 30)
                
                // Submit button to update goal amts, change action later on
                Button("Update Goals") {
                    print("Updated goals: food: \(goalData.foodAmt), drinks: \(goalData.drinkAmt), subscriptions: \(goalData.subsAmt), small payment: \(goalData.smallPayAmt), transport: \(goalData.transportAmt), other: \(goalData.otherAmt)")
                    // API call update in DB
//                    loadBudget() // Updates user budget
                }
                .font(.system(size: 25))
                .padding(10)
                .frame(width: 314, height: 40)
                .background(CategoryColors.principal)
                .cornerRadius(10)
                .foregroundStyle(.white)
            }
            .onAppear() {
//                loadBudget() // Gets user info and updates the weekly budget
            }
        }
    }
}

#Preview {
    goals().environmentObject(GoalData())
}
