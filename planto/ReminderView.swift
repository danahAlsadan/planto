//
//  ReminderView.swift
//  planto
//
//  Created by danah alsadan on 29/04/1447 AH.
//
import SwiftUI

struct ReminderView: View {

    @Binding var isPresented: Bool
    var onSave: (Plant) -> Void = { _ in }
    var onCancelToContent: () -> Void = {}

    @State private var showHome = false
    @State private var plantName = "Pothos"
    @State private var room = "Bedroom"
    @State private var light = "Full sun"
    @State private var wateringDays = "Every day"
    @State private var waterAmount = "20–50 ml"

    var body: some View {
        ZStack {

            VStack(spacing: 16) {
                // MARK: - Header
                HStack {

                    Button(action: {
                        // إغلاق للعودة فقط إلى ContentView (لبداية الدخول)
                        onCancelToContent()
                    }) {
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
                        .foregroundStyle(.white)

                    Spacer()

                    Button(action: {
                        // إنشاء Plant حسب الحقول
                        let p = Plant(
                            name: plantName,
                            room: room,
                            light: light,
                            wateringDays: wateringDays,
                            water: waterAmount
                        )
                        onSave(p)
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(hex: "22BA8C"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // MARK: - Glass Cards اسم النبته
                VStack(spacing: 35) {
                    // Plant Name
                    GlassCard(height: 48) {
                        HStack {
                            Text("Plant Name")
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                            Spacer()
                            TextField("Pothos", text: $plantName)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.gray.opacity(0.8))
                                .textFieldStyle(.plain)
                        }
                    }

                    // Room + Light (نفس منيو الإيدت)
                    GlassCard(height: 90) {
                        VStack(spacing: 0) {
                            MenuRow(icon: "location", label: "Room", selection: $room,
                                    options: ["Bedroom", "Living Room", "Kitchen", "Balcony", "Bathroom"])
                            Divider().background(.white.opacity(0.1))
                            MenuRow(icon: "sun.max", label: "Light", selection: $light,
                                    options: ["Full sun", "Partial Sun", "Low light"])
                        }
                    }

                    // Watering Days + Water (نفس منيو الإيدت)
                    GlassCard(height: 90) {
                        VStack(spacing: 0) {
                            MenuRow(icon: "drop", label: "Watering Days", selection: $wateringDays,
                                    options: ["Every day", "Every 2 days", "Every 3 days",
                                              "Once a week", "Every 10 days", "Every 2 weeks"])
                            Divider().background(.white.opacity(0.1))
               MenuRow(icon: "drop", label: "Water", selection: $waterAmount,
                           options: ["20-50 ml", "50–100 ml", "100-200 ml", "200-300 ml"])
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()
            }
        }
    }
}

// MARK: - GlassCard
private struct GlassCard<Content: View>: View {
    var height: CGFloat
    @ViewBuilder var content: Content
    var body: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.white.opacity(0.1), lineWidth: 0.6)
            )
            
            .frame(height: height)
            .overlay(
                VStack(spacing: 0) { content }
                    .padding(.horizontal, 15)
            )
    }
}

// MARK: - MenuRow
private struct MenuRow: View {
    let icon: String
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
            Text(label)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selection)
                        .foregroundColor(.white.opacity(0.4))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .font(.subheadline)
        .frame(height: 38)
    }
}

// MARK: - Color HEX
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

struct Reminder_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ReminderView(isPresented: .constant(true))
        }
    }
}
