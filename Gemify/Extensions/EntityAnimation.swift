//
//  EntityAnimation.swift
//  Gemify
//
//  Created by Julio Enrique Sanchez Guajardo on 03/10/25.
//

import Foundation
import RealityKit
import Combine

extension Entity {
    private static var dancingSubscriptions: [ObjectIdentifier: AnyCancellable] = [:]
    
    func startDancing(
           in scene: RealityKit.Scene,
           rotationSpeed: Float = .pi / 3,
           shakeAmplitude: Float = 0.01,
           shakeFrequency: Float = 3,
           axis: SIMD3<Float> = [0,1,0]
    ) {
        stopDancing() // ensure no duplicate subscription
        
        var time: Float = 0
        let initialPosition = self.position
        
        let cancellable = scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            guard let self = self else { return }
            
            time += Float(event.deltaTime)
            
            // Rotation
            let rotation = simd_quatf(angle: rotationSpeed * time, axis: axis)
            
            // Shake movement
            let yOffset = shakeAmplitude * sin(shakeFrequency * time)
            
            // Apply transform
            var t = self.transform
            t.rotation = rotation
            t.translation.y = initialPosition.y + yOffset
            self.transform = t
        }
        
        Entity.dancingSubscriptions[ObjectIdentifier(self)] = AnyCancellable(cancellable)
        
    }
    
    func stopDancing() {
            Entity.dancingSubscriptions[ObjectIdentifier(self)] = nil
        }
}
