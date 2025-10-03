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
    
    private var objectsToDelete = ["Panchito1", "Panchito2"] // This should be incomming from Faz's work
    private var objectsToAdd: [String] = ["Diamondtest"] // This should be incomming from Faz's work

    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    @State private var hasOpenedMenu = false

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
