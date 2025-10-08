//
//  CubeImmersiveView.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct ImmersiveView: View {
    @State private var createGem: Bool = false
    @State private var preloaded: [String:Entity] = [:]
    @State private var loaded = false
    
    @State private var objectsToDelete = ["Panchito1", "Panchito2"] // This should be incomming from Faz's work
    @State private var objectsToAdd: [String] = ["Diamondtest"] // This should be incomming from Faz's work

    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    @State private var hasOpenedMenu = false
    
    @State private var elementEntities: [String: Entity] = [:]

    var body: some View {
        RealityView { content in
            
            // Create the container for the objects coming from the menu
            let modelsContainer = Entity()
            modelsContainer.name = "ModelsContainer"
            content.add(modelsContainer)
            
            // Create the blue cube detection
            let step = 0.25
            let radius: Float = 0.02
            
            for x in stride(from: -0.5, through: 0.5, by: step) {
                for y in stride(from: 0.0, through: 1.0, by: step) {
                    for z in stride(from: -3.0, through: -2.0, by: step) {
                        
                        // Check if coordinate is at min or max
                        let isOnXFace = (x == -0.5 || x == 0.5)
                        let isOnYFace = (y == 0.0 || y == 1.0)
                        let isOnZFace = (z == -3.0 || z == -2.0)
                        
                        // An edge happens when at least TWO faces intersect
                        let facesCount = [isOnXFace, isOnYFace, isOnZFace].filter { $0 }.count
                        
                        if facesCount >= 2 {
                            let sphere = ModelEntity(
                                mesh: .generateSphere(radius: radius),
                                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
                            )
                            sphere.position = [Float(x), Float(y), Float(z)]
                            content.add(sphere)
                        }
                    }
                }
            }
            
        } update: { content in
            guard loaded else { return }
            
            if createGem {
                convertElementsToGem(in: &content, from: objectsToDelete, create: objectsToAdd)
                // createGem = false
            }
            
            guard let modelsContainer = content.entities.first(where: { $0.name == "ModelsContainer" }) else {
                return
            }
            
            let currentIds = Set(appModel.droppedModels.map { $0.id })
            for entity in modelsContainer.children {
                if let idComponent = entity.components[ModelIDComponent.self],
                   !currentIds.contains(idComponent.id) {
                    entity.removeFromParent()
                    elementEntities.removeValue(forKey: entity.name)
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
                            elementEntities[model.modelName] = elementEntity
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
                                
                                elementEntities[model.modelName] = scene
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
            await preloadEntities()
            loaded = true
            
            if !hasOpenedMenu {
                hasOpenedMenu = true
                print("🪟 Opening menu window")
                openWindow(id: "MenuWindow")
            }
        }
        
        Button("Toggle 3D model") {
            createGem = true
        }
        .padding()
        .buttonStyle(.borderedProminent)
        
        Button {
            print(appModel.droppedModels)
            print(elementEntities)
            let insideElements = elementEntities.compactMap { name, entity in
                return isInsideCube(entity.position(relativeTo: nil)) ? name : nil
            }
            
            print("Inside cube: \(insideElements)")
            
            let elements = insideElements.compactMap { Element(symbol: $0) }
            
            let resultingGem = Gemify.createGem(from: elements)

            // print(elements.map(\.name))
            
            print("💎 GEMSTONE: \(resultingGem?.name ?? "NO GEM")")
            
            let gemToCreate = [resultingGem?.name ?? ""]
                
            Task { @MainActor in
                await MainActor.run {
                    objectsToDelete = elements.map( {$0.symbol} )
                    objectsToAdd = gemToCreate
                    createGem = true
                }
            }
            
        } label: {
            Text("Get Position")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .buttonStyle(.bordered)
        }
    }
    
    func convertElementsToGem(in content: inout RealityViewContent, from objectsToDelete: [String], create objectsToCreate: [String]) {
        guard let container = content.entities.first(where: { $0.name == "ModelsContainer" }) else {
            print("❌ ModelsContainer not found")
            return
        }
        
        for name in objectsToDelete {
            if let e = container.children.first(where: { $0.name == name }) {
                print("🧽 Removing \(name)")
                
                // 🧩 Remove from container
                e.removeFromParent()
                
                // 🧩 Remove from elementEntities
                elementEntities.removeValue(forKey: name)
                
                // 🧩 Remove from appModel
                if let idComponent = e.components[ModelIDComponent.self] {
                    appModel.removeModel(id: idComponent.id)
                    print("🗑️ Removed \(name) from appModel")
                } else {
                    // Fallback: remove by modelName
                    appModel.droppedModels.removeAll { $0.modelName == name }
                    print("🗑️ Removed \(name) by modelName")
                }
            } else {
                print("⚠️ \(name) not found in container")
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
        let names = ["Diamondtest", "Panchito", "Diamond", "Sapphire"]
        
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
    
    // Function that checks if an object is inside the box.
    func isInsideCube(_ position: SIMD3<Float>) -> Bool {
        let xRange: ClosedRange<Float> = -0.5...0.5
        let yRange: ClosedRange<Float> = 0.0...1.0
        let zRange: ClosedRange<Float> = -3.0...(-2.0)
        
        return xRange.contains(position.x) &&
        yRange.contains(position.y) &&
        zRange.contains(position.z)
    }
    
    private func createProceduralElement(_ element: ChemicalElement) -> Entity {
        let entity = Entity()
        entity.name = element.symbol
        
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

