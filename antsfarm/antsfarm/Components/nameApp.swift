//
//  nameApp.swift
//  antsfarm
//
//  Created by Alejandro Uribe Moreno on 25/10/25.
//

import SwiftUI

struct nameApp: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.15))
            .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.9))
            )
    }
}

#Preview {
    nameApp(text: "ANT FARM")
}
