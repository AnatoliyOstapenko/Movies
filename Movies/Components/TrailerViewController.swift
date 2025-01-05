//
//  TrailerViewController.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 05.01.2025.
//

import UIKit
import SnapKit
import YouTubeiOSPlayerHelper

class TrailerViewController: UIViewController, YTPlayerViewDelegate {
    
    private let trailerKey: String
    private var playerView: YTPlayerView!
    
    init(trailerKey: String) {
        self.trailerKey = trailerKey
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    private func setupPlayer() {
        playerView = YTPlayerView()
        playerView.delegate = self
        view.addSubview(playerView)
        view.backgroundColor = .black
        
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let playerVars = ["playsinline": 1]
        playerView.load(withVideoId: trailerKey, playerVars: playerVars)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .ended || state == .paused {
            self.dismiss(animated: true)
        }
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        self.showAlert(title: Localization.Errors.errorTitle, message: Localization.Errors.youtubeError("\(error.rawValue)"))
        print("Error loading video with error code ")
    }
}

