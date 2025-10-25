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
                home()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                farm()
                    .tabItem {
                        Label("Farm", systemImage: "ant")
                    }
                dashboard()
                    .tabItem {
                        Label("Dashboard", systemImage: "target")
                    }
            }.tint(.purple)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
