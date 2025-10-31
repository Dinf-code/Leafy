//
//  EditProfileView.swift
//  Leafy
//
//  Created by Emeka prince amobi on 2025-11-06.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = "Plant Lover"
    @State private var email = "plantlover@leafy.com"
    @State private var location = "Toronto, Canada"
    @State private var bio = ""
    @State private var showingSavedAlert = false
    
    var body: some View {
        ZStack {
            LeafyTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar Section
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [LeafyTheme.Colors.accent, LeafyTheme.Colors.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                )
                            
                            Button(action: {}) {
                                Image(systemName: "camera.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(LeafyTheme.Colors.accent)
                                    .clipShape(Circle())
                            }
                        }
                        
                        Text("Change Photo")
                            .font(.subheadline)
                            .foregroundColor(LeafyTheme.Colors.accent)
                    }
                    .padding(.top, 20)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Full Name
                        FormField(
                            label: "Full Name",
                            icon: "person.fill",
                            text: $fullName
                        )
                        
                        // Email
                        FormField(
                            label: "Email",
                            icon: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        // Location
                        FormField(
                            label: "Location",
                            icon: "location.fill",
                            text: $location
                        )
                        
                        // Bio
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .foregroundColor(LeafyTheme.Colors.accent)
                                Text("Bio")
                                    .font(.subheadline.bold())
                                    .foregroundColor(LeafyTheme.Colors.text)
                            }
                            
                            TextEditor(text: $bio)
                                .frame(height: 100)
                                .padding(8)
                                .background(LeafyTheme.Colors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: handleSave) {
                        Text("Save Changes")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LeafyTheme.primaryGradient)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(LeafyTheme.Colors.accent)
            }
        }
        .alert("Profile Updated", isPresented: $showingSavedAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your profile has been successfully updated.")
        }
    }
    
    private func handleSave() {
        // Save to UserDefaults or backend
        UserDefaults.standard.set(fullName, forKey: "userFullName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(location, forKey: "userLocation")
        UserDefaults.standard.set(bio, forKey: "userBio")
        
        showingSavedAlert = true
    }
}

// MARK: - Form Field
struct FormField: View {
    let label: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(LeafyTheme.Colors.accent)
                Text(label)
                    .font(.subheadline.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
            }
            
            TextField("Enter \(label.lowercased())", text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                .autocorrectionDisabled(keyboardType == .emailAddress)
                .padding()
                .background(LeafyTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
    }
}
