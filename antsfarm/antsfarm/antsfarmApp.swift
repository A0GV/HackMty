//
//  antsfarmApp.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

@main
struct antsfarmApp: App {
    @StateObject var goalData = GoalData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(goalData)
        }
    }
}
