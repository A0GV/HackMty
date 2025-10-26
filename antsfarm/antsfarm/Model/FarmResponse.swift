//
//  FarmResponse.swift
//  antsfarm
//
//  Created by Monica Guzman on 26/10/25.
//

import Foundation

// Updated structure for new API response
struct FarmResponse: Codable {
    let ants: [Ant]
    let antsCount: String
    let leavesCount: Int

    enum CodingKeys: String, CodingKey {
        case ants
        case antsCount = "ants_count"
        case leavesCount = "leaves_count"
    }
}

struct Ant: Codable {
    let cant: Int
    let name: String
}
