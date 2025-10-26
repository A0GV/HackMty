import SwiftUI
import PhotosUI
import Charts

struct dashboard: View {
    @EnvironmentObject var goalData: GoalData
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    // expenses declarado fuera del body para ayudar al compilador
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

            // Expended/Saved (sin cambios)
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

            // Chart extraída a sub-vista para reducir complejidad
            ExpensesChart(expenses: expenses)
                .frame(height: 180)
                .padding(.horizontal, 16)

            // Mostrar la imagen seleccionada (opcional)
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            // Botón que abre el PhotoPicker (sub-vista)
            PhotoPickerButton(selectedPhotoItem: $selectedPhotoItem, selectedImage: $selectedImage)

            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

// Sub-vista que contiene el Chart (mismo diseño que tenías)
private struct ExpensesChart: View {
    let expenses: [Expense]

    var body: some View {
        Chart {
            ForEach(expenses) { expense in
                BarMark(
                    x: .value("Label", expense.label),
                    yStart: .value("Start", 0),
                    yEnd: .value("Expected", expense.expected)
                )
                .foregroundStyle(expense.color.opacity(0.25))
            }

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
    }
}

// Sub-vista que encapsula el PhotoPicker en iOS 17+
private struct PhotoPickerButton: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    @State private var isShowingPicker: Bool = false

    var body: some View {
        Button {
            // abrir el picker
            isShowingPicker = true
        } label: {
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
        .photosPicker(isPresented: $isShowingPicker, selection: $selectedPhotoItem, matching: .images)
        .padding(.horizontal, 16)
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
}

// Preview
#Preview {
    dashboard().environmentObject(GoalData())
}
