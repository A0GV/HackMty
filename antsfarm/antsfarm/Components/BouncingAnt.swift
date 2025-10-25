//
//  BouncingAnt.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct BouncingAnt: View {
    let antImage: String
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    @State private var position: CGPoint
    @State private var velocity: CGPoint
    
    let antSize: CGFloat = 100
    let speed: CGFloat = 0.5
    let topBoundary: CGFloat = 250  // Área donde terminan los botones
    
    init(antImage: String, screenWidth: CGFloat, screenHeight: CGFloat) {
        self.antImage = antImage
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        
        // Posición inicial aleatoria (debajo de los botones)
        _position = State(initialValue: CGPoint(
            x: CGFloat.random(in: 50...(screenWidth - 50)),
            y: CGFloat.random(in: 250...(screenHeight - 150))
        ))
        
        // Velocidad inicial aleatoria
        _velocity = State(initialValue: CGPoint(
            x: Bool.random() ? 2 : -2,
            y: Bool.random() ? 2 : -2
        ))
    }
    
    var body: some View {
        Image(antImage)
            .resizable()
            .scaledToFit()
            .frame(width: antSize, height: antSize)
            .position(position)
            .onAppear {
                startBouncing()
            }
    }
    
    func startBouncing() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            // Actualizar posición
            position.x += velocity.x * speed
            position.y += velocity.y * speed
            
            // Rebotar en los bordes laterales
            if position.x <= antSize / 2 || position.x >= screenWidth - antSize / 2 {
                velocity.x *= -1
            }
            
            // Rebotar en los bordes verticales
            // Superior: después del área de botones (topBoundary)
            // Inferior: antes del tab bar
            if position.y <= topBoundary || position.y >= screenHeight - 100 {
                velocity.y *= -1
            }
        }
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.3)
            .ignoresSafeArea()
        
        BouncingAnt(
            antImage: "notant",
            screenWidth: 400,
            screenHeight: 800
        )
    }
}
