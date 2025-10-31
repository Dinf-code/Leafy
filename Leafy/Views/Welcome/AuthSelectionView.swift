//
//  AuthSelectionView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//

import SwiftUI

struct AuthSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: AuthTab = .login
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    enum AuthTab {
        case login, signup
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LeafyTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 50))
                            .foregroundColor(LeafyTheme.Colors.accent)
                        
                        Text("Welcome to Leafy")
                            .font(.title.bold())
                            .foregroundColor(LeafyTheme.Colors.text)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    
                    // Tab Selector
                    HStack(spacing: 0) {
                        TabButton(title: "Login", isSelected: selectedTab == .login) {
                            withAnimation { selectedTab = .login }
                        }
                        
                        TabButton(title: "Sign Up", isSelected: selectedTab == .signup) {
                            withAnimation { selectedTab = .signup }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    
                    // Content
                    ScrollView {
                        if selectedTab == .login {
                            LoginForm(onSuccess: {
                                appState.isAuthenticated = true
                                dismiss()
                            }, onError: { message in
                                alertMessage = message
                                showingAlert = true
                            })
                        } else {
                            SignupForm(onSuccess: {
                                appState.isAuthenticated = true
                                dismiss()
                            }, onError: { message in
                                alertMessage = message
                                showingAlert = true
                            })
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(LeafyTheme.Colors.text)
                    }
                }
            }
            .alert("Authentication", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? LeafyTheme.Colors.accent : .secondary)
                
                Rectangle()
                    .fill(isSelected ? LeafyTheme.Colors.accent : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Login Form
struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    let onSuccess: () -> Void
    let onError: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.subheadline.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
                
                TextField("Enter your email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
                
                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    onError("Password reset coming soon!")
                }
                .font(.caption)
                .foregroundColor(LeafyTheme.Colors.accent)
            }
            
            // Login Button
            Button(action: handleLogin) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Login")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(LeafyTheme.primaryGradient)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .padding(.top, 10)
            
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.vertical, 10)
            
            // Social Login Buttons
            VStack(spacing: 12) {
                SocialLoginButton(icon: "apple.logo", title: "Continue with Apple", color: .black) {
                    onError("Apple Sign-In coming soon!")
                }
                
                SocialLoginButton(icon: "g.circle.fill", title: "Continue with Google", color: .black) {
                    onError("Google Sign-In coming soon!")
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func handleLogin() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            
            // Mock validation
            if email.contains("@") && password.count >= 6 {
                onSuccess()
            } else {
                onError("Invalid credentials. Please try again.")
            }
        }
    }
}

// MARK: - Signup Form
struct SignupForm: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var location = ""
    @State private var isLoading = false
    
    let onSuccess: () -> Void
    let onError: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Full Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.subheadline.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
                
                TextField("Enter your full name", text: $fullName)
                    .padding()
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.subheadline.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
                
                TextField("Enter your email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
                
                SecureField("Create a password", text: $password)
                    .padding()
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
                
                Text("Must be at least 6 characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Location Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Location (Region/Country)")
                    .font(.subheadline.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
                
                TextField("e.g., Toronto, Canada", text: $location)
                    .padding()
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Create Account Button
            Button(action: handleSignup) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(LeafyTheme.primaryGradient)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .padding(.top, 10)
            
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.vertical, 10)
            
            // Social Signup Buttons
            VStack(spacing: 12) {
                SocialLoginButton(icon: "apple.logo", title: "Continue with Apple", color: .black) {
                    onError("Apple Sign-In coming soon!")
                }
                
                SocialLoginButton(icon: "g.circle.fill", title: "Continue with Google", color: .black) {
                    onError("Google Sign-In coming soon!")
                }
            }
            
            // Terms
            Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(.horizontal, 40)
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty && !email.isEmpty && !password.isEmpty &&
        email.contains("@") && password.count >= 6
    }
    
    private func handleSignup() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // Mock validation
            if isFormValid {
                onSuccess()
            } else {
                onError("Please check all fields and try again.")
            }
        }
    }
}

// MARK: - Social Login Button
struct SocialLoginButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    AuthSelectionView()
        .environmentObject(AppState())
}
