//
//  FortuneWheelView.swift
//  antsfarm
//
//  Created by CieloVega on 25/10/25.
//

import SwiftUI

struct FortuneWheelView: View {
    @State private var rotationAngle: Double = 0
    @State private var isSpinning = false
    @State private var result: String = ""
    @State public var numLeaves: Int = 50 // How many leaves the user has, will pull from api later on
    @State private var spinAlert: Bool = false // Checks if the user can actually spin the wheel or not; will change to true if not enough leaves to play
    
    let items = RouletteData.items
    let wedgeAngle: Double
    
    init() {
        wedgeAngle = 360.0 / Double(RouletteData.items.count)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Indicador (flecha apuntando hacia abajo) - ARRIBA de la ruleta
            Triangle()
                .fill(CategoryColors.principal)
                .frame(width: 30, height: 40)
                .shadow(radius: 3)
            
            ZStack {
                // Ruleta
                ZStack {
                    ForEach(0..<items.count, id: \.self) { index in
                        WedgeShape(
                            startAngle: Angle(degrees: wedgeAngle * Double(index)),
                            endAngle: Angle(degrees: wedgeAngle * Double(index + 1))
                        )
                        .fill(items[index].color)
                        .overlay(
                            WedgeShape(
                                startAngle: Angle(degrees: wedgeAngle * Double(index)),
                                endAngle: Angle(degrees: wedgeAngle * Double(index + 1))
                            )
                            .stroke(Color.white, lineWidth: 3)
                        )
                    }
                    
                    // Textos horizontales
                    ForEach(0..<items.count, id: \.self) { index in
                        let angle = wedgeAngle * Double(index) + wedgeAngle / 2
                        
                        Text(items[index].title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 80)
                            .position(x: 150, y: 150)
                            .offset(
                                x: cos((angle - 90) * .pi / 180) * 110,
                                y: sin((angle - 90) * .pi / 180) * 110
                            )
                    }
                }
                .frame(width: 300, height: 300)
                .rotationEffect(Angle(degrees: rotationAngle))
                
                // Centro de la ruleta
                Circle()
                    .fill(CategoryColors.principal)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
            }
            
            // Botón para girar
            Button(action: {
                if numLeaves < 50 {
                    spinAlert = true // Not enough leaves alert
                } else {
                    spinWheel()
                }
            }) {
                Text(isSpinning ? "Spinning..." : "SPIN!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(isSpinning ? Color.gray : CategoryColors.principal)
                    .cornerRadius(25)
            }
            .disabled(isSpinning)
            
            // Mention prices
            Text("Cost: 50 leaves")
                .font(.system(size: 20, weight: .semibold))
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .foregroundStyle(CategoryColors.secondaryRed)
            
            // Alert if do not have enough leaves to play
            
            /*.alert("Not enough leaves, keep logging in!", isPresented: $spinAlert) {
                Button("Understood") {}
            }*/
            
            // Temp leaf view
            Text("You have: \(numLeaves) leaves 🍃")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CategoryColors.secondaryRed)
            
            
            // Resultado
            if !result.isEmpty {
                Text(result)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(CategoryColors.principal)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
        }
        //.padding(.top, 50)
        .padding(20)
        .background(Color.white.opacity(0.80)) // Adds white background just so it's overlayed nicely over farm
        .cornerRadius(10)
        // Alert if do not have enough leaves to play - MOVED HERE
        .alert("Not enough leaves", isPresented: $spinAlert) {
            Button("OK") {}
        } message: {
            Text("Keep logging in every day to collect more leaves and play!")
        }
    }
    
    // Spin the wheel
    func spinWheel() {
        guard !isSpinning else { return }
        
        // Update leaves user has, later on will be api call
        numLeaves -= 50
        
        // Sping wheel
        isSpinning = true
        result = ""
        
        // Calcular el índice ganador basado en probabilidades
        let winningIndex = getWeightedRandomIndex()
        
        // Calcular ángulo final
        let spins = Double.random(in: 5...8)
        let finalAngle = (360 * spins) + (wedgeAngle * Double(winningIndex)) + (wedgeAngle / 2)
        
        withAnimation(.easeOut(duration: 3.0)) {
            rotationAngle += finalAngle
        }
        
        // Mostrar resultado después de la animación
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            result = "You got: \(items[winningIndex].title)"
            isSpinning = false
        }
    }
    
    func getWeightedRandomIndex() -> Int {
        let totalWeight = items.reduce(0) { $0 + $1.probability }
        var random = Double.random(in: 0..<totalWeight)
        
        for (index, item) in items.enumerated() {
            random -= item.probability
            if random < 0 {
                return index
            }
        }
        
        return 0
    }
}

// Forma de cuña para la ruleta
struct WedgeShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: startAngle - .degrees(90),
                   endAngle: endAngle - .degrees(90),
                   clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

// Triángulo para el indicador
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    FortuneWheelView()
}
