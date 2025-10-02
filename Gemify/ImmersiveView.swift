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
    
    var body: some View {
        RealityView { content in
            if let entity = try? await Entity(named: "Diamondtest", in: realityKitContentBundle) {
                
                entity.components.set(GestureComponent())
                entity.components.set(InputTargetComponent())
                entity.components.set(CollisionComponent(
                    shapes: [ShapeResource.generateBox(size: [0.1, 0.1, 0.1])],
                    mode: .default,
                    filter: CollisionFilter(group: .all, mask: .all)))
                
                content.add(entity)
            } else {
                print("no object")
            }
        }
        update: { content in
            
        }
        .installGestures()
    }
}



#Preview {
    ImmersiveView()
}


