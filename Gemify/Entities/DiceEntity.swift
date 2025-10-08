//
//  DiceEntity.swift
//  Gemify
//
//  Created by Gizem Coskun on 08/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct DiceEntity {
    static func create(textureName: String) async -> Entity {
        let entity = Entity()
        
        if let texture = try? await TextureResource(named: textureName) {
            let shapeMesh = MeshResource.generateBox(size: 0.1)
            
            var material = UnlitMaterial()
            material.color = PhysicallyBasedMaterial
                .BaseColor(texture: .init(texture))
            
            entity.components.set(ModelComponent(mesh: shapeMesh, materials: [material]))
        } else {
            let shapeMesh = MeshResource.generateBox(size: 0.1)
            let material = SimpleMaterial(color: .systemRed, isMetallic: false)
            entity.components.set(ModelComponent(mesh: shapeMesh, materials: [material]))
        }
        
        entity.components.set(GestureComponent())
        entity.components.set(InputTargetComponent())
        
        let meshBounds = entity.visualBounds(relativeTo: nil)
        let size = meshBounds.extents
        entity.components.set(CollisionComponent(
            shapes: [ShapeResource.generateBox(size: size)]
        ))
        
        return entity
    }
}
