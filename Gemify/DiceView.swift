//
//  DiceView.swift
//  Gemify
//
//  Created by Can Dindar on 05/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct DiceView: View {
    
    var imageName: String
    
    var body: some View {
        
        RealityView { content in
            if let texture = try? await TextureResource(named: imageName) {
                
                let shapeMesh = MeshResource.generateBox(size: 0.05)
                
                var material = UnlitMaterial()
                material.color = PhysicallyBasedMaterial
                    .BaseColor(texture: .init(texture))
                
                let model = ModelEntity(mesh: shapeMesh, materials: [material])
                model.components.set(GestureComponent())
                model.components.set(InputTargetComponent())
                let meshBounds = model.visualBounds(relativeTo: nil)
                let size = meshBounds.extents // actual mesh size
                model.components.set(CollisionComponent(
                    shapes: [ShapeResource.generateBox(size: size)]
                ))
                content.add(model)
            }
        }
        .installGestures()
    }
}

#Preview {
    DiceView(imageName: "carbon")
}
