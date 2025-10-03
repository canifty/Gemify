//
//  ImmersiveSpaceView.swift
//  Gemify
//
//  Created by Gizem Coskun on 03/10/25.
//

// TODO: Delete this file

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveSpaceView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    @State private var hasOpenedMenu = false
    
    var body: some View {
        RealityView { content in
            
            let ambientLight = PointLight()
            ambientLight.light.intensity = 5000
            ambientLight.position = [0, 2, 0]
            content.add(ambientLight)
            
            let directionalLight = DirectionalLight()
            directionalLight.light.intensity = 1000
            directionalLight.look(at: [0, 0, 0], from: [1, 1, 1], relativeTo: nil)
            content.add(directionalLight)
                        
            let modelsContainer = Entity()
            modelsContainer.name = "ModelsContainer"
            content.add(modelsContainer)
            
        } update: { content in
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
                    existingEntity.position = model.position
                } else {
                    Task { @MainActor in
                        do {
                            let scene = try await Entity(named: model.modelName, in: realityKitContentBundle)
                            scene.position = model.position
                            scene.scale = SIMD3<Float>(repeating: 1.0)
                            
                            scene.components.set(InputTargetComponent())
                            scene.components.set(CollisionComponent(
                                shapes: [.generateBox(size: [0.3, 0.3, 0.3])],
                                mode: .default,
                                filter: CollisionFilter(group: .all, mask: .all)
                            ))
                            scene.components.set(ModelIDComponent(id: model.id))
                            
                            modelsContainer.addChild(scene)
                        } catch {
                            print("Error loading \(model.modelName): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let entity = value.entity
                    let startLocation = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let currentLocation = value.convert(value.location3D, from: .local, to: .scene)
                    let offset = currentLocation - startLocation
                    
                    if let idComponent = entity.components[ModelIDComponent.self],
                       let model = appModel.droppedModels.first(where: { $0.id == idComponent.id }) {
                        entity.position = model.position + offset
                    }
                }
                .onEnded { value in
                    let entity = value.entity
                    if let idComponent = entity.components[ModelIDComponent.self] {
                        appModel.updateModelPosition(id: idComponent.id, position: entity.position)
                    }
                }
        )
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
        .environment(AppModel())
}
