//
//  ruleta.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import Foundation
import SwiftUI

// Available rewards
enum RewardType {
    case leaves(Int)
    case ant
    case nothing
}

// To create reward items
struct RouletteItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
    let probability: Double
    let reward: RewardType // Add this property
}

class RouletteData {
    static let items: [RouletteItem] = [
        RouletteItem(title: "+1 leaf 🍃", color: CategoryColors.subscriptions, probability: 5, reward: .leaves(1)),
        RouletteItem(title: "Try Again", color: CategoryColors.drinks, probability: 5, reward: .nothing),
        RouletteItem(title: "+5 leaves 🍃", color: CategoryColors.subscriptions, probability: 2, reward: .leaves(5)),
        RouletteItem(title: "New Ant! 🐜", color: CategoryColors.food, probability: 1, reward: .ant),
        RouletteItem(title: "+5 leaves 🍃", color: CategoryColors.subscriptions, probability: 2, reward: .leaves(5)),
        RouletteItem(title: "Try Again", color: CategoryColors.drinks, probability: 3, reward: .nothing),
        RouletteItem(title: "+1 leaves 🍃", color: CategoryColors.subscriptions, probability: 5, reward: .leaves(1)),
        RouletteItem(title: "Try Again", color: CategoryColors.drinks, probability: 3, reward: .nothing),
        RouletteItem(title: "New Ant! 🐜", color: CategoryColors.food, probability: 1, reward: .ant),
    ]
}
