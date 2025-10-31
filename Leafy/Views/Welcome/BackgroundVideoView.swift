//
//  BackgroundVideoView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//
import SwiftUI
import AVKit

struct BackgroundVideoView: UIViewRepresentable {
    let videoName: String
    let type: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        guard let path = Bundle.main.path(forResource: videoName, ofType: type) else {
            print("❌ Video NOT found: \(videoName).\(type)")
            print("📦 Bundle path:", Bundle.main.bundlePath)
            return view
        }

        print("✅ Video found at: \(path)")

        let url = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)

        // Use AVPlayerLooper for seamless looping
        let looper = AVPlayerLooper(player: player, templateItem: item)
        context.coordinator.looper = looper
        context.coordinator.player = player

        // Create player layer
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        context.coordinator.playerLayer = layer

        // Start playback
        player.play()
        
        print("🎬 Video should be playing now")

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let layer = context.coordinator.playerLayer {
                layer.frame = uiView.bounds
                print("📐 Updated video frame to: \(uiView.bounds)")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var player: AVQueuePlayer?
        var playerLayer: AVPlayerLayer?
        var looper: AVPlayerLooper?
    }
}

#Preview {
    BackgroundVideoView(videoName: "leafy_intro", type: "mp4")
        .ignoresSafeArea()
}
