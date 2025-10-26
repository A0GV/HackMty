import SwiftUI
import PhotosUI
import Charts

struct dashboard: View {
    @EnvironmentObject var goalData: GoalData
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    var expenses: [Expense] {
        [
            Expense(color: CategoryColors.food, value: goalData.foodAmt, expected: goalData.ExpectfoodAmt, label: "Food"),
            Expense(color: CategoryColors.drinks, value: goalData.drinkAmt, expected: goalData.ExpectdrinkAmt, label: "Drinks"),
            Expense(color: CategoryColors.subscriptions, value: goalData.subsAmt, expected: goalData.ExpectsubsAmt, label: "Subscriptions"),
            Expense(color: CategoryColors.smallPayment, value: goalData.smallPayAmt, expected: goalData.ExpectsmallPayAmt, label: "SmallPay"),
            Expense(color: CategoryColors.transport, value: goalData.transportAmt, expected: goalData.ExpecttransportAmt, label: "Transport"),
            Expense(color: CategoryColors.other, value: goalData.otherAmt, expected: goalData.ExpectotherAmt, label: "Other")
        ]
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("My weekly progress")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(CategoryColors.principal)
                .multilineTextAlignment(.center)
            
            // Expended/Saved
            HStack(spacing: 24) {
                VStack {
                    Text("Expended")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(.white)
                    Text("85%")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 180, height: 110)
                .background(CategoryColors.smallPayment)
                .cornerRadius(12)
                VStack {
                    Text("Saved")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(.white)
                    Text("15%")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 150, height: 110)
                .background(CategoryColors.transport)
                .cornerRadius(12)
            }
            Text("Weekly expences")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(CategoryColors.principal)
                .padding(.top, 10)

            Chart {
                // Expected bar (fondo del vaso, más claro)
                ForEach(expenses) { expense in
                    BarMark(
                        x: .value("Label", expense.label),
                        yStart: .value("Start", 0),
                        yEnd: .value("Expected", expense.expected)
                    )
                    .foregroundStyle(expense.color.opacity(0.25))
                }
                // Gasto real (relleno del vaso)
                ForEach(expenses) { expense in
                    BarMark(
                        x: .value("Label", expense.label),
                        yStart: .value("Start", 0),
                        yEnd: .value("Real", min(expense.value, expense.expected))
                    )
                    .foregroundStyle(expense.color)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .frame(height: 180)
            .padding(.horizontal, 16)
            
            // Botón
            Button(action: {}) {
                HStack(spacing: 10) {
                    Image(systemName: "camera")
                        .font(.system(size: 32, weight: .regular))
                    Text("Capture receipt")
                        .font(.system(size: 28, weight: .regular))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(CategoryColors.principal)
                .cornerRadius(18)
            }
            .photosPicker(isPresented: Binding(get: {selectedPhotoItem}, set:{
                show in if !show {selectedPhotoItem = nil}
            }
                                              ),
                          selection: $selectedPhotoItem,
                          matching: .images
            )
            .padding(.horizontal, 16)
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

// Preview
#Preview {
    dashboard().environmentObject(GoalData())
}
