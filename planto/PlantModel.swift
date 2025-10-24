//
//  PlantModel.swift
//  planto
//
//  Created by danah alsadan on 02/05/1447 AH.
//

import SwiftUI

@MainActor
final class PlantsStore: ObservableObject {
    @Published var plants: [Plant] = []
    
    private let saveKey = "SavedPlants_v2"

    init() {
        loadPlants()
        refreshDueWatering()
    }

    func addPlant(_ plant: Plant) {
        plants.append(plant)
        savePlants()
    }

    func updatePlant(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
            savePlants()
        }
    }

    func deletePlant(_ plant: Plant) {
        if let index = plants.firstIndex(of: plant) {
            plants.remove(at: index)
            savePlants()
        }
    }

    func toggleWatered(for plant: Plant) {
        if let index = plants.firstIndex(of: plant) {
            plants[index].isWatered.toggle()
            if plants[index].isWatered {
                plants[index].lastWatered = Date()
            }
            savePlants()
        }
    }

    func allWatered() -> Bool {
        !plants.isEmpty && plants.allSatisfy { $0.isWatered }
    }

    func refreshDueWatering() {
        let now = Date()
        for i in plants.indices {
            if let last = plants[i].lastWatered {
                let gapDays = plants[i].repeatDaysInterval
                if let due = Calendar.current.date(byAdding: .day, value: gapDays, to: last),
                   now >= due {
                    plants[i].isWatered = false
                }
            } else {
                // لم تُسقَ من قبل
                plants[i].isWatered = false
            }
        }
        savePlants()
    }

    private func savePlants() {
        if let encoded = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadPlants() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            plants = decoded
        }
    }
}

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
