//
//  StateOfWater.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 16.06.2021.
//

import Foundation

struct StateOfWater: Decodable {
    let suggests: [Suggests]
}

struct Suggests: Decodable {
    let Address: String
    let OutageBegin: String
    let OutageEnd: String
}
