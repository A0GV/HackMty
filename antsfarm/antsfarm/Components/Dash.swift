//
//  Dash.swift
//  antsfarm
//
//  Created by Adolfo on 25/10/25.
//
import SwiftUI
import Charts

import Foundation

struct Expense: Identifiable {
    let id = UUID()
    let color: Color
    let value: Double // Gasto real
    let expected: Double // Gasto esperado
    let label: String
}
let expenses: [Expense] = [
    Expense(color: Color(hex: "#C33B47"), value: 100, expected: 100, label: "A"),
    Expense(color: Color(hex: "#4974C3"), value: 80, expected: 120, label: "B"),
    Expense(color: Color(hex: "#8B40B9"), value: 90, expected: 90, label: "C"),
    Expense(color: Color(hex: "#C6A13E"), value: 30, expected: 60, label: "D"),
    Expense(color: Color(hex: "#53B33D"), value: 50, expected: 70, label: "E"),
    Expense(color: Color(hex: "#4974C3"), value: 150, expected: 140, label: "F")
]
