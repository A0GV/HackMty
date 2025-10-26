//
//  SlotMachineView.swift
//  antsfarm
//
//  Created by Monica Guzman on 25/10/25.
//

import SwiftUI

struct SlotMachineView: View {
    @State private var isSpinning = false
    @State private var result: String = ""
    @State private var displayedItem: String = "Spin to Win!"
    @Binding var numLeaves: Int // Store num of leaves for internal logic
    @Binding var numAnts: Int // Binds number of ants
    @State private var spinAlert: Bool = false
    
    let items = RouletteData.items // To iterate between possible rewards
    
    var onLeavesChange: (Int) -> Void // Function to call API
    
    var body: some View {
        VStack {
            Text("Prize Wheel")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(CategoryColors.principal)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
            
            // Cost and leaves info
            Text("Cost: 50 leaves")
                .font(.system(size: 20, weight: .semibold))
                .padding(10)
            //.background(Color.white)
                .cornerRadius(10)
                .foregroundStyle(CategoryColors.secondaryRed)
                .padding(.bottom, 5)
            
            // Slot machine display
            ZStack {
                // Displays the spinning through options
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(width: 280, height: 120)
                    .shadow(color: .gray.opacity(0.3), radius: 10)
                
                // Adds rectangle
                RoundedRectangle(cornerRadius: 20)
                    .stroke(CategoryColors.principal, lineWidth: 4)
                    .frame(width: 280, height: 120)
                
                // Spins through text
                Text(displayedItem)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(CategoryColors.principal)
                    .multilineTextAlignment(.center)
            }
            
            // Spin button
            Button(action: {
                if numLeaves < 50 {
                    spinAlert = true
                } else {
                    spinSlot()
                }
            }) {
                Text(isSpinning ? "Spinning..." : "Spin!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(isSpinning ? Color.gray : CategoryColors.principal)
                    .cornerRadius(25)
            }
            .disabled(isSpinning)
            .padding(.bottom, 15)
            
            /*Text("Available: \(numLeaves) leaves 🍃")
             .font(.system(size: 18, weight: .semibold))
             .foregroundStyle(CategoryColors.secondaryRed)*/
            
            // Result
            if !result.isEmpty {
                Text(result)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(CategoryColors.principal)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.80))
        .cornerRadius(10)
        .alert("Not enough leaves", isPresented: $spinAlert) {
            Button("OK") {}
        } message: {
            Text("Keep logging in every day to collect more leaves and play!")
        }
    }
    
    func spinSlot() {
        guard !isSpinning else { return }
        
        // Call API to deduct 50 leaves
        onLeavesChange(-50)
        
        isSpinning = true
        result = ""
        
        // Get winning index and item
        let winningIndex = getWeightedRandomIndex()
        let winningItem = items[winningIndex]
        
        // Animate through random items
        var counter = 0
        let totalFlips = 20
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            counter += 1
            
            // Show random items while spinning
            if counter < totalFlips {
                displayedItem = items.randomElement()?.title ?? "SPIN!"
            } else {
                // Show winning item
                displayedItem = winningItem.title
                
                // Process the reward
                processReward(winningItem.reward)
                
                result = "You got: \(winningItem.title)"
                isSpinning = false
                timer.invalidate()
            }
        }
    }
        
    func processReward(_ reward: RewardType) {
        switch reward {
        case .leaves(let amount):
            // Call API to add leaves
            onLeavesChange(amount)
        case .ant:
            numAnts += 1
            //print("Got ant - implement ant API call later")
        case .nothing:
            // No reward, do nothing
            break
        }
    }
    
    func getWeightedRandomIndex() -> Int {
        let totalWeight = items.reduce(0) { $0 + $1.probability }
        var random = Double.random(in: 0..<totalWeight)
        
        for (index, item) in items.enumerated() {
            random -= item.probability
            if random < 0 {
                return index
            }
        }
        
        return 0
    }
}

#Preview {
    SlotMachineView(
        numLeaves: .constant(200), numAnts: .constant(1),
        onLeavesChange: { amount in
            print("Should update leaves by: \(amount)")
        }
    )
}
