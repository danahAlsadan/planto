//
//  DoneView.swift
//  planto
//
//  Created by danah alsadan on 01/05/1447 AH.
//
import SwiftUI

struct DoneView: View {
    var onAddPlant: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - العنوان في الأعلى
                VStack(alignment: .leading, spacing: 6) {
                    Text("My Plants 🌱")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1)
                        .padding(.trailing, 30)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // MARK: - محتوى الصفحة في المنتصف (بدون ما يتحرك للأعلى)
                VStack(spacing: 24) {
                    Image("All Done")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)

                    Text("All Done! 🎉")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text("All Reminders Completed")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 100)

                Spacer()
            }
            
            // MARK: - زر الإضافة في الأسفل
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: onAddPlant) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(Color(hex: "22BA8C"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 40)
                }
            }
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
    DoneView(onAddPlant: {})
}
