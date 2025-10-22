//
//  SoundManager.swift
//  Gemify
//
//  Created by Gizem Coskun on 20/10/25.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(named fileName: String, volume: Float = 0.7) {
        guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Sound file not found: \(fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = volume
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }

}

