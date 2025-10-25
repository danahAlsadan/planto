//
//  PlantModel.swift
//  planto
//
//  Created by danah alsadan on 02/05/1447 AH.
//

import Foundation

struct Plant: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var room: String
    var light: String
    var wateringDays: String
    var water: String
    var isWatered: Bool
    var lastWatered: Date?

    init(
        id: UUID = UUID(),
        name: String,
        room: String,
        light: String,
        wateringDays: String,
        water: String,
        isWatered: Bool = false,
        lastWatered: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.room = room
        self.light = light
        self.wateringDays = wateringDays
        self.water = water
        self.isWatered = isWatered
        self.lastWatered = lastWatered
    }

    // كم يوم بين كل سقي بناءً على اختيار المستخدم
    var repeatDaysInterval: Int {
        switch wateringDays.lowercased() {
        case "every day": return 1
        case "every 2 days": return 2
        case "every 3 days": return 3
        case "once a week": return 7
        case "every 10 days": return 10
        case "every 2 weeks": return 14
        default: return 1
        }
    }
}
