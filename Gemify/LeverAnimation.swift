//
//  LeverAnimation.swift
//  Gemify
//
//  Created by Can Dindar on 03/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct LeverAnimation: View {
    
    @State private var showGem = false
    @State private var subscription: EventSubscription?
    @State private var lever: Entity?
    
    var body: some View {
        RealityView { content in
            if let lever = try? await Entity(named: "Lever", in: realityKitContentBundle) {
                lever.components.set(InputTargetComponent())
                
                let meshBounds = lever.visualBounds(relativeTo: nil)
                var size = meshBounds.extents
                size.y *= 1.7

                lever.components.set(CollisionComponent(
                    shapes: [ShapeResource.generateBox(size: size)]
                ))
                lever.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
                lever.scale = SIMD3<Float>(repeating: 0.10)
                lever.position = [1.0, 0.40, -2.5]
                
                content.add(lever)
                
                self.lever = lever
                
                subscription = content.subscribe(
                    to: AnimationEvents.PlaybackCompleted.self,
                    on: lever
                ) { event in
                    showGem = true
                }
            }
        }
        .installGestures()
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    showGem = false
                    
                    if let leverEntity = lever,
                       let animation = leverEntity.availableAnimations.first {
                        leverEntity.playAnimation(animation)
                    }
                    NotificationCenter.default.post(name: Notification.Name("TriggerCheckRecipe"), object: nil
                    )
                }
        )
    }
}

#Preview {
    LeverAnimation()
}
