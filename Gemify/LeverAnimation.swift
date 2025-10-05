//
//  LeverAnimation.swift
//  Gemify
//
//  Created by Can Dindar on 03/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

/* TODO: WHEN ANIMATION ENDS DISPLAY THE GEM
 - detect when animation ends
*/
struct LeverAnimation: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        
        RealityView { content in
            if let lever = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                lever.components.set(GestureComponent())
                lever.components.set(InputTargetComponent())
                let meshBounds = lever.visualBounds(relativeTo: nil)
                let size = meshBounds.extents // actual mesh size
                lever.components.set(CollisionComponent(
                    shapes: [ShapeResource.generateBox(size: size)]
                ))
                content.add(lever)
                
            }
        }
        update: { content in
            
            guard let lever = content.entities.first else { return }
            
            if isAnimating {
                lever.availableAnimations.forEach { animation in
                    lever.playAnimation(animation, transitionDuration: 3)
                }
            } else {
                lever.stopAllAnimations()
            }
        }
        .installGestures()
        
        //        when tapped on the lever start/stop the animation
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { _ in
                    isAnimating.toggle()
                }
        )
    }
}
//    @State var subscriptions: [EventSubscription] = []
//let sub = content.subscribe(to: AnimationEvents.PlaybackCompleted.self,
//                            on: lever) { event in
//    print("Animation completed!")
// subscriptions.append(sub)
//}

#Preview {
    LeverAnimation()
}
