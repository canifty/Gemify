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
    
    private var objectsToDelete = ["Panchito1", "Panchito2"] // This should be incomming from Faz's work
    private var objectsToAdd: [String] = ["Diamondtest"] // This should be incomming from Faz's work

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
                               print("🧪 Element: \(elementData.name)")
                               
                               // Symbol yerine name kullan
                               let diceEntity = await DiceEntity.create(textureName: elementData.name)
                               
                               diceEntity.position = model.position
                               diceEntity.components.set(ModelIDComponent(id: model.id))
                               modelsContainer.addChild(diceEntity)
                               elementEntities[model.modelName] = diceEntity
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
            
        } label: {
            Text("Get Position")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .buttonStyle(.bordered)
        }
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
    
    // Function that checks if an object is inside the box.
    func isInsideCube(_ position: SIMD3<Float>) -> Bool {
        let xRange: ClosedRange<Float> = -0.5...0.5
        let yRange: ClosedRange<Float> = 0.0...1.0
        let zRange: ClosedRange<Float> = -3.0...(-2.0)
        
        return xRange.contains(position.x) &&
        yRange.contains(position.y) &&
        zRange.contains(position.z)
    }
}


#Preview {
    ImmersiveView()
}
