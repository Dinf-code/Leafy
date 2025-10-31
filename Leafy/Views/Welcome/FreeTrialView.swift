//
//  FreeTrialView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//

import SwiftUI

struct FreeTrialView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coreDataManager: CoreDataManager
    @AppStorage("guestAttempts") private var attempts = 0
    @State private var showIdentify = false
    @State private var showAuth = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
                    
                    Text("Identify Your Plant")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Try it free, up to 50 times")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 20) {
                    InstructionRow(
                        icon: "camera.fill",
                        title: "Open the camera",
                        description: "Tap to take a photo of your plant"
                    )
                    
                    InstructionRow(
                        icon: "viewfinder",
                        title: "Position your plant",
                        description: "Center the leaves in frame for best results"
                    )
                    
                    InstructionRow(
                        icon: "sparkles",
                        title: "Get instant results",
                        description: "Name, confidence score, and care tips"
                    )
                }
                .padding(.horizontal, 30)
                
                VStack(spacing: 8) {
                    Text("Attempts left: \(50 - attempts)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        if attempts < 50 {
                            attempts += 1
                            appState.isGuest = true
                            showIdentify = true
                        } else {
                            showAuth = true
                        }
                    }) {
                        Text(attempts < 50 ? "Try Now" : "Create Account")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button(action: { showAuth = true }) {
                        Text("Login / Sign Up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showIdentify) {
            IdentifyView()
                .environmentObject(appState)
                .environmentObject(coreDataManager)
        }
        .fullScreenCover(isPresented: $showAuth) {
            AuthSelectionView()
        }
    }
}

// MARK: - Helper View
struct InstructionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    FreeTrialView()
        .environmentObject(AppState())
}
