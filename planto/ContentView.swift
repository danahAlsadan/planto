//
//  ContentView.swift
//  planto
//
//  Created by danah alsadan on 27/04/1447 AH.
//

import SwiftUI

struct ContentView: View {
    @State private var showHome = false
    @State private var showList = false
    @EnvironmentObject private var store: PlantsStore

    var body: some View {
        ZStack {
            if showHome {
            } else {
                VStack {
                    Text("My Plants 🌱")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .padding(.top, 50)

                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 1)
                        .padding(.horizontal, 32)

                    Spacer()
                }

                VStack(spacing: 24) {
                    Image("plant_icon")
                        .resizable()
                        .padding(.all, 0.237)
                        .scaledToFit()
                        .frame(width: 141, height: 233)

                    Text("Start your plant journey!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, -20.61)

                    Text("Now all your plants will be in one place and\nwe will help you take care of them :) 🪴")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button(action: { showHome = true }) {
                        Text("Set Plant Reminder")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 280, height: 41)
                            .background(Color(red: 92/255, green: 244/255, blue: 198/255))
                            .cornerRadius(30)
                            .padding([.top, .leading, .trailing], 50)
                    }
                }
            }
        }
        .sheet(isPresented: $showHome) {
            ReminderView(
                isPresented: $showHome,
                onSave: { newPlant in
                    store.addPlant(newPlant)
                    showHome = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        showList = true
                    }
                },
                onCancelToContent: {
                    showHome = false
                }
            )
            .presentationDetents([.fraction(0.99)])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(false)
        }
        .fullScreenCover(isPresented: $showList) {
            PlantsListView()
                .environmentObject(store)
        }
    }
}

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
    ContentView()
        .environmentObject(PlantsStore())
}
