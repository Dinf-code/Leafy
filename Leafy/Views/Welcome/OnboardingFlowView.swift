//
//  OnboardingFlowView.swift
//  Leafy
//
//  Created by Emeka prince amobi on 2025-11-05.
//

import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            WelcomeView()
            FreeTrialView()
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingFlow()
}
