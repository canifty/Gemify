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
    private static var isDancing: Bool = true
    
    public func startDancing(
           in scene: RealityKit.Scene?,
           rotationSpeed: Float = .pi / 3,
           shakeAmplitude: Float = 0.01,
           shakeFrequency: Float = 3,
           axis: SIMD3<Float> = [0.07,1,0.07]
    ) {
        // ✅ If this entity is already dancing, don't start again
        let id = ObjectIdentifier(self)
        guard Entity.dancingSubscriptions[id] == nil else {
            print("⚠️ \(self.name) is already dancing.")
            return
        }
        stopDancing() // ensure no duplicate subscription
        
        guard let scene = scene else {
            print("Warning: Entity not in a scene yet!")
            return
        }
        
        var time: Float = 0
        let initialTransform = self.transform
        
        let cancellable = scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            guard let self = self else { return }
            
            time += Float(event.deltaTime)
            
            // Rotation
            let rotation = simd_quatf(angle: rotationSpeed * time, axis: axis)
            
            // Shake movement
            let yOffset = shakeAmplitude * sin(shakeFrequency * time)
            
            // Apply transform
            var t = initialTransform
            t.rotation = rotation * initialTransform.rotation
            t.translation.y = initialTransform.translation.y + yOffset
            //t.translation.y = initialPosition.y + yOffset
            self.transform = t
        }
        
        Entity.dancingSubscriptions[ObjectIdentifier(self)] = AnyCancellable(cancellable)
        
    }
    
    public func stopDancing() {
        // ✅ Only stop if there’s an active animation for this entity
        let id = ObjectIdentifier(self)
        guard Entity.dancingSubscriptions[id] != nil else {
            print("⚠️ \(self.name) is not dancing, nothing to stop.")
            return
        }
            Entity.dancingSubscriptions[ObjectIdentifier(self)] = nil
        }
}
