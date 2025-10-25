//
//  plantoApp.swift
//  planto
//
//  Created by danah alsadan on 27/04/1447 AH.
//

import SwiftUI

@main
struct PlantoApp: App {
    @StateObject private var store = PlantViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
