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
    
    @State private var isAnimating = false
    @State private var showGem = false
    @State private var subscription: EventSubscription?
    
    var body: some View {
        RealityView { content in

            if let lever = try? await Entity(named: "Lever", in: realityKitContentBundle) {
                lever.components.set(GestureComponent())
                lever.components.set(InputTargetComponent())
                
                let meshBounds = lever.visualBounds(relativeTo: nil)
                let size = meshBounds.extents
                lever.components.set(CollisionComponent(
                    shapes: [ShapeResource.generateBox(size: size)]
                ))
                lever.transform.rotation = simd_quatf(angle: .pi , axis: [0, 1, 0])
                lever.scale = SIMD3<Float>(repeating: 0.10)
                lever.position = [1.0, 0.40, -2.5]

                content.add(lever)
                
                
                subscription = content.subscribe(
                    to: AnimationEvents.PlaybackCompleted.self,
                    on: lever
                ) { event in
                    showGem = true
                }
            }
        }
        update: { content in
            guard let lever = content.entities.first else { return }
             
            if isAnimating {
                lever.availableAnimations.forEach { animation in
                    lever.playAnimation(animation)
                }
            }
//            else {
//                lever.stopAllAnimations()
//            }
        }
        .installGestures()
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { _ in
                    isAnimating.toggle()
                    if isAnimating {
                        showGem = false
                        NotificationCenter.default.post(name: Notification.Name("TriggerCheckRecipe"), object: nil)
                    }
                }
        )

        

//        if showGem {
//            RealityView { content in
//                if let gem = try? await Entity(named: "Diamond", in: realityKitContentBundle) {
//                    gem.components.set(GestureComponent())
//                    gem.components.set(InputTargetComponent())
//                    
//                    let meshBounds = gem.visualBounds(relativeTo: nil)
//                    let size = meshBounds.extents
//                    gem.components.set(CollisionComponent(
//                        shapes: [ShapeResource.generateBox(size: size)]
//                    ))
//                    content.add(gem)
//                }
//            }
//            .installGestures()
//
//        }
    }
}

#Preview {
    LeverAnimation()
}
