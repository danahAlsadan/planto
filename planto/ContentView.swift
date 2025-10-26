//
//  ContentView.swift
//  planto
//
//  Created by danah alsadan on 27/04/1447 AH.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PlantViewModel
    
    @State private var showReminder = false
    @State private var showList = false
    @State private var showDone = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // شاشة البداية
            if !showList && !showDone {
                VStack(spacing: 0) {
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
                    
                    Button(action: { showReminder = true }) {
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
            
            // شاشة قائمة النباتات
            if showList && !showDone {
                PlantsListView(
                    onAllDone: { showDone = true },
                    onAddNew: { showReminder = true }
                )
                .environmentObject(store)
            }
            
            // شاشة DoneView
            if showDone {
                DoneView(onAddPlant: {
                    showDone = false
                    showReminder = true
                })
            }
        }
        // شاشة الإضافة
        .sheet(isPresented: $showReminder) {
            ReminderView(
                isPresented: $showReminder,
                onSave: { newPlant in
                    store.addPlant(newPlant)
                    showReminder = false
                    showList = true
                },
                onCancelToContent: { showReminder = false }
            )
            .presentationDetents([.fraction(0.95)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(40)
            .interactiveDismissDisabled(false)
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
    ContentView().environmentObject(PlantViewModel())
}
