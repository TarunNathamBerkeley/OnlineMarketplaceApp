//
//  LoopingVideoPlayer.swift
//  grace_li_hi_ios
//
//  Created by Tarun Natham 2 on 8/3/25.
//


import SwiftUI
import AVKit

struct LoopingVideoPlayer: UIViewControllerRepresentable {
    let videoURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVQueuePlayer()
        let playerViewController = AVPlayerViewController()
        let item = AVPlayerItem(url: videoURL)
        let looper = AVPlayerLooper(player: player, templateItem: item)

        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        player.play()
        
        context.coordinator.looper = looper  // Keep looper alive
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var looper: AVPlayerLooper?
    }
}
