//
//  SoundManager.swift
//  Gemify
//
//  Created by Gizem Coskun on 20/10/25.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var players: [String: AVAudioPlayer] = [:]
    private let queue = DispatchQueue(label: "com.candindar.Gemify", qos: .background)
    private var didActivateSession = false
    
    private init() {}
    
    static func bootstrap() {
        DispatchQueue.global(qos: .background).async {
            do {
                let session = AVAudioSession.sharedInstance()
                // .ambient mixes with others and respects Silent switch (good for games/AR)
                try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
                try session.setActive(true)
                SoundManager.shared.didActivateSession = true
                print("🎧 Audio session activated (background)")
            } catch {
                print("⚠️ Audio session setup failed: \(error)")
            }
        }
    }
    
    func preloadSoundsAsync(_ fileNames: [String]) {
        queue.async { [weak self] in
            guard let self else { return }
            for name in fileNames {
                guard self.players[name] == nil else { continue }
                
                guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
                    print("⚠️ Sound not found: \(name)")
                    continue
                }
                
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    DispatchQueue.main.async {
                        self.players[name] = player
                    }
                } catch {
                    print("❌ Failed to preload sound \(name): \(error)")
                }
            }
            print("✅ Finished async preloading sounds: \(fileNames.joined(separator: ", "))")
        }
    }
    
    func playSound(named fileName: String, volume: Float = 0.7) {
        if let player = players[fileName] {
            player.currentTime = 0 // rewind for reuse
            player.volume = volume
            player.play()
        } else {
            print("⚠️ Sound \(fileName) not preloaded — loading now.")
            preloadSoundsAsync([fileName])
        }
    }
    
}

