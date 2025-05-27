//
//  Item.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
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
