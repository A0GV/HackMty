//
//  antsfarmApp.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

@main
struct antsfarmApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    //@AppStorage("userId") private var userId: Int = 0
    
    @StateObject var goalData = GoalData()
    var body: some Scene {
        WindowGroup {
            if(isLoggedIn){
                ContentView().environmentObject(goalData)
            }else{
                Login()
            }
        }
    }
}
