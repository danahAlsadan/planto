//
//  EditPlantView.swift
//  planto
//
//  Created by danah alsadan on 30/04/1447 AH.
//

import SwiftUI

struct EditPlantView: View {
    @Environment(\.dismiss) private var dismiss

    var plant: Plant
    var onSave: (Plant) -> Void = { _ in }
    var onDelete: () -> Void = {}

    @State private var plantName: String = ""
    @State private var room: String = ""
    @State private var light: String = ""
    @State private var wateringDays: String = ""
    @State private var waterAmount: String = ""

    var body: some View {
        ZStack {

            VStack(spacing: 30) {
                // MARK: - Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .background(Color(white: 0.2))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Set Reminder")
                        .font(.headline)
                        .foregroundColor(.primary)
                     

                    Spacer()

                    Button {
                        var updated = plant
                        updated.name = plantName
                        updated.room = room
                        updated.light = light
                        updated.wateringDays = wateringDays
                        updated.water = waterAmount
                        onSave(updated)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(hex: "22BA8C"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 5)
                .padding(.top, 15)

                // MARK: - Plant Name
                GlassCard(height: 55) {
                    HStack {
                        Text("Plant Name")
                            .foregroundColor(.primary)
                            .font(.subheadline)
                        Spacer()
                        TextField("Enter name", text: $plantName)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 5)
                }

                // MARK: - Room + Light
                GlassCard(height: 90) {
                    VStack(spacing: 0) {
                        MenuRow(icon: "location", label: "Room", selection: $room,
                                options: ["Bedroom", "Living Room", "Kitchen", "Balcony", "Bathroom"])
                        Divider().background(.primary.opacity(0.1))
                        MenuRow(icon: "sun.max", label: "Light", selection: $light,
                                options: ["Full sun", "Partial Sun", "Low light"])
                    }
                }

                // MARK: - Watering Days + Water
                GlassCard(height: 90) {
                    VStack(spacing: 0) {
                        MenuRow(icon: "drop", label: "Watering Days", selection: $wateringDays,
                                options: ["Every day", "Every 2 days", "Every 3 days",
                                         "Once a week", "Every 10 days", "Every 2 weeks"])
                        Divider().background(.primary.opacity(0.1))
                        MenuRow(icon: "drop", label: "Water", selection: $waterAmount,
                       options: ["20-50 ml", "50-100 ml", "100-200 ml", "200-300 ml"])
                    }
                }

                // MARK: - Delete Button
                GlassCard(height: 55) {
                    Button(action: {
                        onDelete()
                        dismiss()
                    }) {
                        Text("Delete Reminder")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            plantName = plant.name
            room = plant.room
            light = plant.light
            wateringDays = plant.wateringDays
            waterAmount = plant.water
        }
    }
}

// MARK: - GlassCard & MenuRow
private struct GlassCard<Content: View>: View {
    var height: CGFloat
    @ViewBuilder var content: Content
    var body: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            
            .frame(height: height)
            .overlay(
                VStack(spacing: 0) { content }
                    .padding(.horizontal, 15)
            )
    }
}

private struct MenuRow: View {
    let icon: String
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.primary)
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selection)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .font(.subheadline)
        .frame(height: 38)
    }
}

// MARK: - Color Helper
private extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: s).scanHexInt64(&int)
        self.init(
            red: Double((int >> 16) & 0xFF)/255,
            green: Double((int >> 8) & 0xFF)/255,
            blue: Double(int & 0xFF)/255
        )
    }
}

#Preview {
    EditPlantView(plant: Plant(name: "Pothos", room: "Bedroom", light: "Full sun", wateringDays: "Every day", water: "20–50 ml"))
}
