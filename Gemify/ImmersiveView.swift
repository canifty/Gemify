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
    @State private var createGem: Bool = false
    @State private var preloaded: [String:Entity] = [:]
    @State private var loaded = false
    
    private var objectsToDelete = ["Panchito1", "Panchito2"]
    private var objectsToAdd: [String] = ["Diamondtest"]
    
    var body: some View {
        RealityView { _ in
            
        } update: { content in
            guard loaded else { return }
            
            if createGem {
                convertElementsToGem(in: &content, from: objectsToDelete, create: objectsToAdd)
            }
        }
        .installGestures()
        .task {
            await preloadEntities()
            loaded = true
        }
        
        Button("Toggle 3D model") {
            createGem = true
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }
    
    func convertElementsToGem(in content: inout RealityViewContent, from objectsToDelete: [String], create objectsToCreate: [String]) {
        for name in objectsToDelete {
            if let e = content.entities.first(where: { $0.name == name }) {
                print("Removing \(name)")
                content.remove(e)
            }
        }
        
        for name in objectsToAdd {
            if content.entities.first(where: { $0.name == name }) == nil,
               let e = preloaded[name] {
                let clone = e.clone(recursive: true)
                clone.name = name
                clone.position = [0, 1.0, -1.5]
                print("Adding \(name)")
                content.add(clone)
            }
        }
    }
    
    func preloadEntities() async {
        let names = ["Diamondtest", "Panchito"]
        
        for name in names {
            if let entity = try? await Entity(named: name, in: realityKitContentBundle) {
                entity.name = name

                entity.components.set(GestureComponent())
                entity.components.set(InputTargetComponent())
                entity.components.set(
                    CollisionComponent(
                        shapes: [ShapeResource.generateBox(size: [0.3, 0.3, 0.3])],
                        mode: .default,
                        filter: CollisionFilter(group: .all, mask: .all)
                    )
                )
                preloaded[name] = entity
            } else {
                print("❌ Failed to load \(name)")
            }
        }
    }
}

#Preview {
    ImmersiveView()
}
