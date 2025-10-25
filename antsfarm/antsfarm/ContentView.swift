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
                        Label("Home", systemImage: "house.circle")
                    }
                dashboard()
                    .tabItem {
                        Label("Dashboard", systemImage: "house.circle")
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
