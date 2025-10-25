//
//  PlantsViewModel.swift
//  planto
//
//  Created by danah alsadan on 03/05/1447 AH.
//

import SwiftUI

@MainActor
final class PlantViewModel: ObservableObject {
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
