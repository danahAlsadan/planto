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
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - العنوان
                VStack(alignment: .leading, spacing: 19) {
                    Text("My Plants 🌱")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.top, 12)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.09))
                        .frame(height: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // MARK: - المحتوى في المنتصف
                VStack(spacing: 24) {
                    Image("plant_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 141, height: 233)
                        .padding(.top, -6)
                    Text("Start your plant journey!")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.top, -9)
                    Text("Now all your plants will be in one place and\nwe will help you take care of them :)🪴")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .offset(y: -30)
                
                Spacer()
                
                // MARK: - الزر في الأسفل
                Button(action: { showHome = true }) {
                    Text("Set Plant Reminder")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "22BA8C"))
                        .cornerRadius(25)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 190)
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
            .presentationDetents([.fraction(0.95)])
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
