//
//  MyPlantsView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-06.
//
import SwiftUI

struct MyPlantsView: View {
    @ObservedObject private var store = PlantStore.shared
    @State private var showAddPlant = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        ZStack {
            LeafyTheme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    HStack {
                        Text("My Plants")
                            .font(.largeTitle.bold())
                            .foregroundColor(LeafyTheme.Colors.text)

                        Spacer()
                        
                        // Edit button
                        if !store.plants.isEmpty {
                            Button(action: {
                                withAnimation {
                                    editMode = editMode == .active ? .inactive : .active
                                }
                            }) {
                                Text(editMode == .active ? "Done" : "Edit")
                                    .foregroundColor(LeafyTheme.Colors.accent)
                            }
                        }

                        Button(action: { showAddPlant = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(LeafyTheme.Colors.accent)
                        }
                    }
                    .padding(.horizontal)

                    if store.plants.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("No plants yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Tap the + button to add your first plant!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                            ForEach(store.plants) { plant in
                                ZStack(alignment: .topLeading) {
                                    NavigationLink(destination: RegisteredPlantDetailView(plant: plant)) {
                                        PlantCardView(plant: plant)
                                    }
                                    .disabled(editMode == .active)
                                    
                                    // Delete button in edit mode
                                    if editMode == .active {
                                        Button(action: {
                                            withAnimation {
                                                store.remove(plant)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.red)
                                                .background(Circle().fill(Color.white))
                                        }
                                        .offset(x: -8, y: -8)
                                        .transition(.scale)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                .padding(.bottom, 80)
            }
        }
        // ✅ REMOVED: .navigationTitle("My Plants") - was causing double header
        .sheet(isPresented: $showAddPlant) {
            AddPlantView()
        }
    }
}

#Preview {
    NavigationStack {
        MyPlantsView()
            .environmentObject(AppState())
    }
}
