//
//  ContentView.swift
//  planto
//
//  Created by danah alsadan on 27/04/1447 AH.
//

import SwiftUI

struct ContentView: View {
    // لا تغيير بصري — فقط ربط
    @State private var showHome = false               // يفتح Reminder كـ sheet من تحت
    @State private var showList = false               // يفتح اللِست بعد الحفظ
    @EnvironmentObject private var store: PlantsStore

    var body: some View {
        ZStack {

            if showHome {
                // نستخدم sheet بدل إدراج مباشر للحفاظ على الباكقراوند ثابت
            } else {
                // العنوان فقط (خارج الـ VStack الأصلي)
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

                // الكود الأصلي بالضبط بدون أي تغيير بصري
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
        // Reminder يظهر من تحت لفوق كبروحة (الخلفية ثابتة)
        .sheet(isPresented: $showHome) {
            ReminderView(
                isPresented: $showHome,
                onSave: { newPlant in
                    store.addPlant(newPlant)
                    // بعد الحفظ ينزل الشيت ويظهر اللست مباشرة بدون تحريك الخلفية
                    showHome = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        showList = true
                    }
                },
                onCancelToContent: {
                    // زر X في البداية يرجع فقط لـ ContentView
                    showHome = false
                }
            )
            .presentationDetents([.medium, .large]) // لا يغيّر مقاسات المحتوى
            .presentationDragIndicator(.visible)
        }
        // بعد أول إضافة نفتح اللست
        .fullScreenCover(isPresented: $showList) {
            PlantsListView()
                .environmentObject(store)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PlantsStore())
}
