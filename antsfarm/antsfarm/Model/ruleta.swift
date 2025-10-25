//
//  ruleta.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import Foundation
import SwiftUI

struct RouletteItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
    let probability: Double // Peso de probabilidad
}

class RouletteData {
    static let items: [RouletteItem] = [
        // Mezclados para que no estén todos juntos
        RouletteItem(title: "+1 leaf 🍃", color: CategoryColors.subscriptions, probability: 5),
        RouletteItem(title: "Try Again", color: CategoryColors.drinks, probability: 5),
        RouletteItem(title: "+5 leaves 🍃", color: CategoryColors.subscriptions, probability: 2),
        RouletteItem(title: "New Ant! 🐜", color: CategoryColors.food, probability: 2),
        RouletteItem(title: "+5 leaves 🍃", color: CategoryColors.subscriptions, probability: 2),
        RouletteItem(title: "Try Again", color: CategoryColors.drinks, probability: 3),
        RouletteItem(title: "+1 leaves 🍃", color: CategoryColors.subscriptions, probability: 5),
        RouletteItem(title: "Try Again", color: CategoryColors.drinks, probability: 3),
        RouletteItem(title: "New Ant! 🐜", color: CategoryColors.food, probability: 2),
    ]
}
