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
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    @State private var hasOpenedMenu = false
    
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
            
            let modelsContainer = Entity()
            modelsContainer.name = "ModelsContainer"
            content.add(modelsContainer)
        }
        update: { content in
            guard let modelsContainer = content.entities.first(where: { $0.name == "ModelsContainer" }) else {
                return
            }
            
            let currentIds = Set(appModel.droppedModels.map { $0.id })
            for entity in modelsContainer.children {
                if let idComponent = entity.components[ModelIDComponent.self],
                   !currentIds.contains(idComponent.id) {
                    entity.removeFromParent()
                }
            }
            
            for model in appModel.droppedModels {
                if let existingEntity = modelsContainer.children.first(where: { entity in
                    entity.components[ModelIDComponent.self]?.id == model.id
                }) {
                    //existingEntity.position = model.position
                } else {
                    Task { @MainActor in
                        do {
                            let scene = try await Entity(named: model.modelName, in: realityKitContentBundle)
                            scene.position = model.position
                            scene.scale = SIMD3<Float>(repeating: 1.0)
                            
                            scene.components.set(GestureComponent())
                            scene.components.set(InputTargetComponent())
                            scene.components.set(CollisionComponent(
                                shapes: [ShapeResource.generateBox(size: [0.1, 0.1, 0.1])],
                                mode: .default,
                                filter: CollisionFilter(group: .all, mask: .all)))
                            
                            scene.components.set(ModelIDComponent(id: model.id))
                            
                            modelsContainer.addChild(scene)
                        } catch {
                            print("Error loading \(model.modelName): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .installGestures()
        .task {
            if !hasOpenedMenu {
                hasOpenedMenu = true
                print("🪟 Opening menu window")
                openWindow(id: "MenuWindow")
            }
        }
    }
}

#Preview {
    ImmersiveView()
}
