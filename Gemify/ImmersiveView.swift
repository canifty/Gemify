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
                        if model.isProceduralElement, let elementData = model.elementData {
                            // Create procedural element
                            let elementEntity = createProceduralElement(elementData)
                            elementEntity.position = model.position
                            elementEntity.components.set(ModelIDComponent(id: model.id))
                            modelsContainer.addChild(elementEntity)
                        } else {
                            // Load 3D model
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
        }
        .installGestures()
        .dropDestination(for: DraggableElement.self) { items, location in
            guard let element = items.first else { return false }
            
            // Find the corresponding ChemicalElement
            if let chemElement = chemicalElements.first(where: { $0.symbol == element.symbol }) {
                appModel.addElement(chemElement)
                return true
            }
            return false
        }
        .task {
            if !hasOpenedMenu {
                hasOpenedMenu = true
                print("🪟 Opening menu window")
                openWindow(id: "MenuWindow")
            }
        }
    }
    
    private func createProceduralElement(_ element: ChemicalElement) -> Entity {
        let entity = Entity()
        
        // Create sphere for the element
        let sphere = MeshResource.generateSphere(radius: 0.1)
        let material = SimpleMaterial(color: getElementColor(element), isMetallic: true)
        let modelComponent = ModelComponent(mesh: sphere, materials: [material])
        entity.components.set(modelComponent)
        
        // Add text label
        let textMesh = MeshResource.generateText(
            element.symbol,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1, weight: .bold)
        )
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = Entity()
        textEntity.components.set(ModelComponent(mesh: textMesh, materials: [textMaterial]))
        textEntity.position = SIMD3<Float>(0, 0.15, 0)
        entity.addChild(textEntity)
        
        // Add interaction components
        entity.components.set(GestureComponent())
        entity.components.set(InputTargetComponent())
        entity.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: 0.1)],
            mode: .default,
            filter: CollisionFilter(group: .all, mask: .all)))
        
        return entity
    }
    
    private func getElementColor(_ element: ChemicalElement) -> UIColor {
        switch element.symbol {
        case "H": return .systemRed
        case "Li", "Na", "Ca": return .systemPurple
        case "Be", "Mg", "Al": return .systemBlue
        case "B", "C", "Si": return .systemBrown
        case "O", "F": return .systemGreen
        case "P": return .systemOrange
        case "Cu", "Zr": return .systemCyan
        default: return .systemGray
        }
    }
}

#Preview {
    ImmersiveView()
}

