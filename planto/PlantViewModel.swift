//
//  PlantsViewModel.swift
//  planto
//
//  Created by danah alsadan on 03/05/1447 AH.
//

import SwiftUI
import UserNotifications

@MainActor
final class PlantViewModel: ObservableObject {
    @Published var plants: [Plant] = []
    
    private let saveKey = "SavedPlants_v2"

    init() {
        loadPlants()
        refreshDueWatering()
        requestNotificationPermission()

        // 🔔 اختبار تلقائي عند فتح التطبيق (للتأكد من عمل الإشعارات)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.scheduleTestNotification()
        }
    }

    func addPlant(_ plant: Plant) {
        plants.append(plant)
        savePlants()
        scheduleTestNotification() // 🔔 إرسال إشعار بعد الإضافة
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
                scheduleWateringReminder(for: plants[index]) // 🔔 تذكير حقيقي حسب التكرار
            }
            savePlants()
        }
    }

    func allWatered() -> Bool {
        !plants.isEmpty && plants.allSatisfy { $0.isWatered }
    }

    // ✅ تعديل refreshDueWatering
    func refreshDueWatering() {
        let now = Date()
        for i in plants.indices {
            if let last = plants[i].lastWatered {
                let gapDays = plants[i].repeatDaysInterval
                if let nextDue = Calendar.current.date(byAdding: .day, value: gapDays, to: last) {
                    // إذا لم تمر المدة بعد → تبقى النبتة مخفية
                    if now < nextDue {
                        plants[i].isWatered = true
                    } else {
                        // المدة انتهت → ترجع تظهر
                        plants[i].isWatered = false
                    }
                }
            } else {
                // نبتة ما تم سقيها من قبل
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

// MARK: - 🔔 Local Notification Extension
extension PlantViewModel {
    /// طلب إذن الإشعارات والتحقق من إعداد النظام
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    print(granted ? "✅ Notifications allowed" : "❌ Notifications denied")
                }
            case .denied:
                print("🚫 Notifications are denied in Settings.")
            case .authorized, .provisional, .ephemeral:
                print("✅ Notifications already allowed")
            @unknown default:
                break
            }
        }
    }

    /// إرسال إشعار بعد 3 ثواني — حتى عند القفل (Background)
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let’s water your plant "
        content.sound = UNNotificationSound.default

        // بعد 3 ثواني بالضبط
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled successfully")
            }
        }
    }

    /// 🔔 جدولة إشعار حقيقي للنبتة بناءً على تكرار السقي
    func scheduleWateringReminder(for plant: Plant) {
        guard let lastWatered = plant.lastWatered else { return }

        // نحسب التاريخ القادم حسب عدد الأيام (repeatDaysInterval)
        let nextDate = Calendar.current.date(byAdding: .day, value: plant.repeatDaysInterval, to: lastWatered) ?? Date()

        let content = UNMutableNotificationContent()
        content.title = "Time to water \(plant.name) 💧"
        content.body = "Your \(plant.name) needs some love today 🌿"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "watering_\(plant.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling reminder for \(plant.name): \(error.localizedDescription)")
            } else {
                print("✅ Reminder scheduled for \(plant.name) at \(nextDate)")
            }
        }
    }
}
