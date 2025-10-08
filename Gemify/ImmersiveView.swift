//
//  CubeImmersiveView.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var parentEntity: Entity?

    var body: some View {
        RealityView { content in
            // Create parent and child entities
            let parent = Entity()
            if let diamond = try? await Entity(named: "Diamondtest", in: realityKitContentBundle) {
                
                // Enable gestures on the parent, not the child
                parent.components.set(GestureComponent())
                parent.components.set(InputTargetComponent())
                parent.components.set(CollisionComponent(
                    shapes: [ShapeResource.generateBox(size: [0.1, 0.1, 0.1])],
                    mode: .default,
                    filter: CollisionFilter(group: .all, mask: .all)
                ))
                
                // Attach child (animated) entity
                parent.addChild(diamond)
                
                // Add to scene
                content.add(parent)
                
                // Store references
                parentEntity = parent
            } else {
                print("no object")
            }
        }
        update: { content in
            
        }
        .installGestures()
        
        VStack {
            Button("Start Dancing") {
                parentEntity?.children.first?.startDancing(in: parentEntity?.scene)
            }
            Button("Stop Dancing") {
                parentEntity?.children.first?.stopDancing()
            }
        }
        .padding()
    }
}

#Preview {
    ImmersiveView()
}
