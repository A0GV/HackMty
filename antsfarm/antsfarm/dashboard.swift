import SwiftUI
import Charts
struct dashboard: View {
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("My weekly progress")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "#6B3B33"))
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
                .background(Color(hex: "#E2A946"))
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
                .background(Color(hex: "#54793D"))
                .cornerRadius(12)
            }
            Text("Weekly expences")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "#6B3B33"))
                .padding(.top, 10)

            Chart {
                // Expected bar (fondo del vaso, más claro)
                ForEach(expenses) { expense in
                    BarMark(
                        x: .value("Label", expense.label),
                        yStart: .value("Start", 0),
                        yEnd: .value("Expected", expense.expected)
                    )
                    .foregroundStyle(Color.gray.opacity(0.50))
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
                .background(Color(hex: "#6B3B33"))
                .cornerRadius(18)
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

// Helper para colores hexadecimales
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Preview
#Preview {
    dashboard()
}
