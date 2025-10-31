//
//  WelcomeView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            BackgroundVideoView(videoName: "leafy_intro", type: "mp4")
                .ignoresSafeArea()
            
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("Never Guess Again!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Leafy knows when your plants need you")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "chevron.up")
                        .font(.title3)
                    Text("Swipe to continue")
                        .font(.subheadline)
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
}
