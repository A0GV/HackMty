//
//  FarmResponse.swift
//  antsfarm
//
//  Created by Monica Guzman on 26/10/25.
//

import Foundation

// Recieves base farm info
struct FarmResponse: Codable {
    let farm: Farm
    let success: Bool
}

struct Farm: Codable {
    let id: Int
    let user_id: Int
    //let ants_count: Int
    let leaves_count: Int
    let bonus_leaves_earned: Int
}
