import SwiftUI
import AVKit

struct LoopingVideoPlayer: UIViewControllerRepresentable {
    let videoURL: URL
    var isPlaying: Bool = true

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVQueuePlayer()
        let item = AVPlayerItem(url: videoURL)
        let looper = AVPlayerLooper(player: player, templateItem: item)

        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = false
        vc.videoGravity = .resizeAspectFill

        context.coordinator.player = player
        context.coordinator.looper = looper

        if isPlaying {
            player.play()
        }

        return vc
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if isPlaying {
            context.coordinator.player?.play()
        } else {
            context.coordinator.player?.pause()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var looper: AVPlayerLooper?
        var player: AVQueuePlayer?
    }
}
