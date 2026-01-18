//
//  PlantsListView.swift
//  planto
//
//  Created by danah alsadan on 29/04/1447 AH.
//
import SwiftUI

struct PlantsListView: View {
    @EnvironmentObject private var store: PlantViewModel

    @State private var showAdd = false
    @State private var editingPlant: Plant? = nil
    
    var onAllDone: () -> Void = {}
    var onAddNew: () -> Void = {}


    private var lovedCount: Int { store.plants.filter { $0.isWatered }.count }
    private var totalCount: Int { store.plants.count }
    
    private var progress: CGFloat {
        guard totalCount > 0 else { return 0 }
        return CGFloat(lovedCount) / CGFloat(totalCount)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("My Plants 🌱")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.top, 12)

                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.trailing, 30)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    Spacer(minLength: geometry.size.height * 0.05)

                    // MARK: - Status + Progress
                    VStack(alignment: .leading, spacing: 14) {
                        if lovedCount == 0 {
                            Text("Your plants are waiting for a sip 💦")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("\(lovedCount) of your plants feel loved today ✨")
                                .foregroundColor(.white.opacity(0.95))
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 8)

                                Capsule()
                .fill(
           LinearGradient(
           colors: lovedCount == 0
                          ? [Color.white.opacity(0.2)]
           : [Color(hex: "83FBD7"), Color(hex: "16C087")],
                           startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * progress, height: 8)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.9), value: progress)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)

                    // MARK: - Plants List (عرض الكل لكن النبتة المسقاة تبقى باهتة)
                    List {
                        ForEach(store.plants) { plant in
                            PlantRowView(
                                plant: plant,
                                onToggle: {
                                    store.toggleWatered(for: plant)
                                    checkDone()
                                },
                                onTapName: { editingPlant = plant }
                            )
                            .opacity(plant.isWatered ? 0.4 : 1.0) //  تظل باهتة بعد التشيك
                            .animation(.easeInOut, value: plant.isWatered)
                            .listRowBackground(Color.black)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    store.deletePlant(plant)
                                    checkDone()
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 20, weight: .semibold))
                                        .padding(10)
                                        .background(Capsule().fill(Color.red))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .padding(.horizontal, 30)

                    Spacer(minLength: geometry.size.height * 0.05)
                }

                //  زر الإضافة
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { onAddNew() }) {
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
            // Edit Plant Sheet
            .sheet(item: $editingPlant) { plant in
                EditPlantView(
                    plant: plant,
                    onSave: { updated in
                        store.updatePlant(updated)
                        editingPlant = nil
                    },
                    onDelete: {
                        store.deletePlant(plant)
                        editingPlant = nil
                        checkDone()
                    }
                )
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
                .interactiveDismissDisabled(false)
            }
        }
    }

    private func checkDone() {
        if store.allWatered() {
            onAllDone()
        }
    }
}

// Plant Row
private struct PlantRowView: View {
    let plant: Plant
    let onToggle: () -> Void
    let onTapName: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "location")
                Text("in \(plant.room)")
            }
            .font(.footnote)
            .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 10) {
                Button(action: onToggle) {
                    ZStack {
                        if plant.isWatered {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "22BA8C"))
                                .font(.system(size: 24))
                        } else {
                            Circle()
                                .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .offset(y: 7)
                }

                Button(action: onTapName) {
                    Text(plant.name)
                        .font(.system(size: 22, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.8)
                        .foregroundColor(plant.isWatered ? Color.white.opacity(0.4) : .white)
                        .padding(.leading, 9)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            HStack(spacing: 10) {
                chip(icon: "sun.max", text: plant.light, active: plant.isWatered, baseColor: Color(hex: "CCC785"))
                    .padding(.leading, 40)
                chip(icon: "drop", text: plant.water, active: plant.isWatered, baseColor: Color(hex: "CAF3FB"))
            }
        }
        .listRowSeparator(.hidden)
        .padding(.vertical, 10)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    private func chip(icon: String, text: String, active: Bool, baseColor: Color) -> some View {
        let fadedColor = baseColor.opacity(0.4)
        return HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text).fontWeight(.semibold)
        }
        .font(.footnote)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.1)))
        .foregroundColor(active ? fadedColor : baseColor)
    }
}

// Color HEX Helper
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
