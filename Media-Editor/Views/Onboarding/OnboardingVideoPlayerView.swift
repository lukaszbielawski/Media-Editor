//
//  OnboardingVideoPlayerView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 30/06/2024.
//

import AVFoundation
import SwiftUI

class VideoPlayerUIView: UIView {
    private let player: AVPlayer

    init(player: AVPlayer) {
        self.player = player
        super.init(frame: .zero)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: self.player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let playerLayer = self.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = self.bounds
        }
    }
}

struct VideoPlayerView: UIViewRepresentable {
    private let player: AVPlayer

    init(fileName: String, fileType: String) {
        if let filePath = Bundle.main.path(forResource: fileName, ofType: fileType) {
            let url = URL(fileURLWithPath: filePath)
            self.player = AVPlayer(url: url)
            self.player.actionAtItemEnd = .none
        } else {
            self.player = AVPlayer()
        }
    }

    func makeUIView(context: Context) -> UIView {
        self.player.play()
        return VideoPlayerUIView(player: self.player)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
