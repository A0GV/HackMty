//
//  ContentView.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView{
                dashboard()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                farm()
                    .tabItem {
                        Label("Farm", systemImage: "ant")
                    }
                goals()
                    .tabItem {
                        Label("Goals", systemImage: "target")
                    }
            }.tint(CategoryColors.principal)
        }
        
        //.padding()
    }
}

#Preview {
    ContentView().environmentObject(GoalData())
}
