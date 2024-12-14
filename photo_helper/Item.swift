//
//  Item.swift
//  photo_helper
//
//  Created by Mateusz Placek on 14/12/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
