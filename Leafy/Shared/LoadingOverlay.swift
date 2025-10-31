//
//  LoadingOverlay.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//
import SwiftUI

// MARK: - Loading Overlay (Full Screen)
struct LoadingOverlay: View {
    var text: String = "Loading..."
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text(text)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 20)
        }
        .transition(.opacity.combined(with: .scale))
    }
}

// MARK: - Inline Loading Spinner
struct InlineLoadingView: View {
    var text: String = "Loading..."
    var tintColor: Color = LeafyTheme.Colors.accent
    
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(tintColor)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Error Banner
struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil
    var onRetry: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Error")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            
            Spacer()
            
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Retry")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Success Banner
struct SuccessBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
                .font(.title3)
            
            Text(message)
                .font(.subheadline.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(LeafyTheme.Colors.success.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(LeafyTheme.Colors.accent.opacity(0.6))
            
            Text(title)
                .font(.title3.bold())
                .foregroundColor(LeafyTheme.Colors.text)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(LeafyTheme.primaryGradient)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Skeleton Loading
struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.1),
                        Color.gray.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(x: isAnimating ? 200 : -200)
            .animation(
                Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Shimmer Effect Modifier
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 400
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Pulse Animation
struct PulseView: View {
    @State private var isPulsing = false
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .scaleEffect(isPulsing ? 1.5 : 0.5)
            .opacity(isPulsing ? 0 : 1)
            .animation(
                Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Usage Examples in Preview
#Preview("Loading Overlay") {
    ZStack {
        Color.gray
        LoadingOverlay(text: "Identifying plant...")
    }
}

#Preview("Error Banner") {
    VStack {
        ErrorBanner(
            message: "Failed to load plant data. Please try again.",
            onDismiss: {},
            onRetry: {}
        )
        Spacer()
    }
    .padding(.top, 50)
    .background(LeafyTheme.Colors.background)
}

#Preview("Success Banner") {
    VStack {
        SuccessBanner(
            message: "Plant added successfully!",
            onDismiss: {}
        )
        Spacer()
    }
    .padding(.top, 50)
    .background(LeafyTheme.Colors.background)
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "leaf.fill",
        title: "No Plants Yet",
        subtitle: "Add your first plant to get started with smart care reminders",
        actionTitle: "Add Plant",
        action: {}
    )
    .background(LeafyTheme.Colors.background)
}

#Preview("Skeleton Loading") {
    VStack(spacing: 16) {
        SkeletonView()
            .frame(height: 200)
        
        HStack {
            SkeletonView()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView()
                    .frame(height: 20)
                SkeletonView()
                    .frame(height: 16)
                    .frame(maxWidth: 200)
            }
        }
    }
    .padding()
    .background(LeafyTheme.Colors.background)
}
