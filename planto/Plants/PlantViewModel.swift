//
//  PlantsViewModel.swift
//  planto
//
//  Created by danah alsadan on 03/05/1447 AH.
//

import SwiftUI
@preconcurrency import UserNotifications

@MainActor
final class PlantViewModel: ObservableObject {
    @Published var plants: [Plant] = []
    private let saveKey = "SavedPlants_v2"

    init() {
        loadPlants()
        refreshDueWatering()
        requestNotificationPermission()
    }

    func addPlant(_ plant: Plant) {
        //  إذا كل النباتات كانت مسقاة (All Done)، نخفيها مؤقتاً
        if allWatered() {
            plants = plants.filter { !$0.isWatered }
        }

        plants.append(plant)
        plants.sort { $0.name < $1.name }
        savePlants()

        //  إشعار بعد 3 ثواني بنفس النص المطلوب
        scheduleWateringNotification()
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
        guard let index = plants.firstIndex(of: plant) else { return }
        plants[index].isWatered.toggle()

        if plants[index].isWatered {
            plants[index].lastWatered = Date()
            scheduleReturn(for: plants[index])
            scheduleWateringNotification() //  نفس النص بعد 3 ثواني
        }

        savePlants()
    }

    func allWatered() -> Bool {
        !plants.isEmpty && plants.allSatisfy { $0.isWatered }
    }

    func refreshDueWatering() {
        let now = Date()
        for i in plants.indices {
            if let last = plants[i].lastWatered {
                let gapDays = plants[i].repeatDaysInterval
                if let nextDue = Calendar.current.date(byAdding: .day, value: gapDays, to: last),
                   now >= nextDue {
                    plants[i].isWatered = false
                }
            }
        }
        savePlants()
    }

    //  النبتة ترجع بعد وقتها المحدد
    private func scheduleReturn(for plant: Plant) {
        guard let last = plant.lastWatered else { return }
        let gapDays = plant.repeatDaysInterval

        // للتجربة السريعة: كل يوم = 10 ثواني
        let secondsPerDay = 10.0
        let delay = Double(gapDays) * secondsPerDay

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let index = self.plants.firstIndex(of: plant) {
                self.plants[index].isWatered = false
                self.savePlants()
            }
        }
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

// MARK: - 🔔 Notifications
extension PlantViewModel {
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print(granted ? "✅ Notifications allowed" : "❌ Notifications denied")
        }
    }

    //  إشعار ثابت بعد 3 ثوانٍ بنفس النص المطلوب
    func scheduleWateringNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let’s water your plant"
        content.sound = UNNotificationSound.default

        // ⏱ بعد 3 ثوانٍ
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled in 3s (Hey! let’s water your plant)")
            }
        }
    }
}
