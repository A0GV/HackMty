import SwiftUI
import Charts

class GoalData: ObservableObject {
    @Published var foodAmt: Double = 0
    @Published var drinkAmt: Double = 0
    @Published var subsAmt: Double = 0
    @Published var smallPayAmt: Double = 0
    @Published var transportAmt: Double = 0
    @Published var otherAmt: Double = 0
    
    @Published var ExpectfoodAmt: Double = 0
    @Published var ExpectdrinkAmt: Double = 0
    @Published var ExpectsubsAmt: Double = 0
    @Published var ExpectsmallPayAmt: Double = 0
    @Published var ExpecttransportAmt: Double = 0
    @Published var ExpectotherAmt: Double = 0
    
    //Para la cosa de monica
    @Published var hojas: Int = 0 // Will update when pull from db
    @Published var id_user: Int = 1 // Just for testing
}

struct Expense: Identifiable {
    let id = UUID()
    let color: Color
    let value: Double
    let expected: Double
    let label: String
}

//// Esta función la puedes poner donde la necesites, por ejemplo en la vista:
//func expenses(from goalData: GoalData) -> [Expense] {
//    [
//        Expense(color: Color(hex: "#C33B47"), value: goalData.foodAmt, expected: goalData.foodAmt, label: "Food"),
//        Expense(color: Color(hex: "#4974C3"), value: goalData.drinkAmt, expected: goalData.drinkAmt, label: "Drinks"),
//        Expense(color: Color(hex: "#8B40B9"), value: goalData.subsAmt, expected: goalData.subsAmt, label: "Subscriptions"),
//        Expense(color: Color(hex: "#C6A13E"), value: goalData.smallPayAmt, expected: goalData.smallPayAmt, label: "SmallPay"),
//        Expense(color: Color(hex: "#53B33D"), value: goalData.transportAmt, expected: goalData.transportAmt, label: "Transport"),
//        Expense(color: Color(hex: "#4974C3"), value: goalData.otherAmt, expected: goalData.otherAmt, label: "Other")
//    ]
//}
