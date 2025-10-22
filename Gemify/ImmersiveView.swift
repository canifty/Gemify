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
import AVFoundation

struct ImmersiveView: View {
    // MARK: - State Properties
    @State private var preloaded: [String: Entity] = [:]
    @State private var loaded = false
    @State private var cancellable: AnyCancellable? = nil
    
    @State private var elementEntities: [String: Entity] = [:]
    @State private var gemEntities: [UUID: Entity] = [:]
    
    @State private var modelsContainer: Entity?
    
    @State private var soundManager = SoundManager.shared

    // MARK: - Environment
    @Environment(AppModel.self) private var appModel
    
    // MARK: - Constants
    private let cubeXRange: ClosedRange<Float> = -0.5...0.5
    private let cubeYRange: ClosedRange<Float> = 0.0...1.0
    private let cubeZRange: ClosedRange<Float> = -3.0...(-2.0)
    private let gemScale: Float = 1.0
    
    var body: some View {
        RealityView { content in
            setupInitialScene(content: content)
            
            // Create the blue cube detection
            /*
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
             */
        } update: { content in
            guard loaded else { return }
            updateScene(content: content)
        }
        .installGestures()
        .task {
            await initializeScene()
        }
        .onAppear {
            startAutoCheck()
        }
        .onDisappear {
            cancellable?.cancel()
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: Notification.Name("TriggerCheckRecipe"), object: nil, queue: .main) { _ in
                checkRecipe()
                appModel.isImmersiveSpaceOpen = true
            }
        }
        .onDisappear {
            removeEverything()
            NotificationCenter.default.removeObserver(self, name: Notification.Name("TriggerCheckRecipe"), object: nil)
            appModel.isImmersiveSpaceOpen = false
        }
        .onChange(of: appModel.deleteEverything) { _, _ in
            removeEverything()
        }
        
        LeverAnimation()
//        debugButtons
    }
    
    // MARK: - UI Components
//    private var debugButtons: some View {
//        VStack(spacing: 16) {
//            Button("Check Recipe") {
//                checkRecipe()
//            }
//            .buttonStyle(.bordered)
//        }
//        .padding()
//    }
    
  
    // MARK: - Scene Setup
    private func setupInitialScene(content: RealityViewContent) {
        let container = Entity()
        container.name = "ModelsContainer"
        content.add(container)
        
        Task { @MainActor in
            modelsContainer = container
        }
        
        Task { @MainActor in
            if let boardMixer = try? await Entity(named: "BoardMixer", in: realityKitContentBundle) {
                boardMixer.position = [0.0, 0.0, -2.5]
                boardMixer.scale = SIMD3<Float>(0.5, 0.5, 0.5)
                content.add(boardMixer)
                print("BoardMixer added")
            } else {
                print("Failed to load BoardMixer")
            }
        }
    }
    
    // MARK: - Scene Updates
    private func updateScene(content: RealityViewContent) {
        guard let container = content.entities.first(where: { $0.name == "ModelsContainer" }) else {
            return
        }
        
        if modelsContainer == nil {
            Task { @MainActor in
                modelsContainer = container
            }
        }
        
        removeDeletedModels(from: container)
        addNewModels(to: container)
        
    }
    
    private func removeDeletedModels(from container: Entity) {
        let currentIds = Set(appModel.droppedModels.map { $0.id })
        
        for entity in container.children {
            guard let idComponent = entity.components[ModelIDComponent.self] else {
                continue
            }
            
            // Don't remove gems!
            let isGem = gemEntities.keys.contains(idComponent.id)
            
            if !isGem && !currentIds.contains(idComponent.id) {
                entity.removeFromParent()
                
                elementEntities = elementEntities.filter { key, value in
                    value !== entity
                }
            }
        }
    }
    
    private func addNewModels(to container: Entity) {
        for model in appModel.droppedModels {
            if container.children.contains(where: { $0.components[ModelIDComponent.self]?.id == model.id }) {
                continue
            }
            
            Task { @MainActor in
                await addModel(model, to: container)
            }
        }
    }
    
    private func addModel(_ model: DroppedModel, to container: Entity) async {
        if model.isProceduralElement, let elementData = model.elementData {
            addProceduralElement(elementData, model: model, to: container)
        } else {
            await add3DModel(model, to: container)
        }
    }
    
    private func addProceduralElement(_ element: ChemicalElement, model: DroppedModel, to container: Entity) {
        let elementEntity = createProceduralElement(element)
        let randomX = Float.random(in: -0.5...0.5)
        let randomY = Float.random(in: 0.5...1.5)
        elementEntity.position = SIMD3<Float>(randomX, randomY, -1.0)
        elementEntity.components.set(ModelIDComponent(id: model.id))
        container.addChild(elementEntity)
        
        soundManager.playSound(named: "element_place")
        
        let uniqueKey = "\(element.symbol)_\(model.id)"
        elementEntities[uniqueKey] = elementEntity
        
        print("Element added: \(element.symbol) with key: \(uniqueKey)")
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            checkRecipe()
        }
    }
    
    private func add3DModel(_ model: DroppedModel, to container: Entity) async {
        do {
            let scene = try await Entity(named: model.modelName, in: realityKitContentBundle)
            scene.position = model.position
            scene.scale = SIMD3<Float>(repeating: 1.0)
            scene.name = model.modelName
            
            var gestures = GestureComponent()
            gestures.canAnimateOnGrab = true
            scene.components.set(gestures)
            scene.components.set(InputTargetComponent())
            scene.components.set(CollisionComponent(
                shapes: [ShapeResource.generateBox(size: [0.1, 0.1, 0.1])],
                mode: .default,
                filter: CollisionFilter(group: .all, mask: .all)
            ))
            scene.components.set(ModelIDComponent(id: model.id))
            
            container.addChild(scene)
            elementEntities[model.modelName] = scene
        } catch {
            print("❌ Error loading \(model.modelName): \(error.localizedDescription)")
        }
    }
   
    
    // MARK: - Recipe & Gem Creation
    private func checkRecipe() {
        
        let insideElements = getElementsInsideCube(elementEntities: elementEntities, gemEntities: gemEntities, xRange: cubeXRange, yRange: cubeYRange, zRange: cubeZRange)
                
        guard !insideElements.isEmpty else {
            return
        }
        
        let elements = insideElements.compactMap { Element(symbol: $0) }
        
        print("Element Set: \(elements.map { $0.symbol })")
        
        if let matchedGemstone = createGem(from: elements) {
            createGemIfNeeded(matchedGemstone, elements: elements)
            appModel.discoverGemstone(named: matchedGemstone.name)
        } else {
            soundManager.playSound(named: "gemstone_fail")
            print("No gems can be created with these elements: \(elements.map { $0.symbol }.joined(separator: ", "))")
        }
    }
    
    private func createGemIfNeeded(_ gemstone: Gemstone, elements: [Element]) {
        removeElements(elements)
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            soundManager.playSound(named: "gemstone_create")
            createGemEntity(gemFileName: gemstone.name)
        }
    }
    
    private func removeElements(_ elements: [Element]) {
        for element in elements {
            let entitiesToRemove = elementEntities.filter { key, entity in
                let symbol = key.components(separatedBy: "_").first ?? key
                
                guard let idComponent = entity.components[ModelIDComponent.self] else {
                    return false
                }
                let isGem = gemEntities.keys.contains(idComponent.id)
                
                return symbol == element.symbol && !isGem
            }
            
            for (uniqueKey, entity) in entitiesToRemove {
                if let idComponent = entity.components[ModelIDComponent.self] {
                    appModel.removeModel(id: idComponent.id)
                }
                
                entity.removeFromParent()
                elementEntities.removeValue(forKey: uniqueKey)
            }
        }
    }
    
    private func removeEverything() {
        for (uniqueKey, entity) in elementEntities {
            if let idComponent = entity.components[ModelIDComponent.self] {
                appModel.removeModel(id: idComponent.id)
            }
            entity.removeFromParent()
            elementEntities.removeValue(forKey: uniqueKey)
        }
        
    }
    
    private func createGemEntity(gemFileName: String) {
        
        guard let container = modelsContainer else {
            return
        }
        
        guard let gemEntity = preloaded[gemFileName] else {
            print("Gem not preloaded: \(gemFileName)")
            return
        }
                
        let gemPosition = calculateCubeCenter(xRange: cubeXRange, yRange: cubeYRange, zRange: cubeZRange)
        let gemId = UUID()
        
        let clone = gemEntity.clone(recursive: true)
        clone.name = gemFileName
        clone.position = gemPosition
        clone.scale = SIMD3<Float>(repeating: gemScale)
        clone.components.set(ModelIDComponent(id: gemId))
        
        container.addChild(clone)
        
        gemEntities[gemId] = clone
        elementEntities["\(gemFileName)_\(gemId)"] = clone
    }
    
    // MARK: - Animation System
    private func startAutoCheck() {
        cancellable?.cancel()
        
        cancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                for (_, entity) in elementEntities {
                    if let idComponent = entity.components[ModelIDComponent.self],
                       gemEntities.keys.contains(idComponent.id) {
                        continue
                    }
                    
                    let position = entity.position(relativeTo: nil)
                    if isInsideCube(position, xRange: cubeXRange, yRange: cubeYRange, zRange: cubeZRange) {
                        for child in entity.children {
                            child.startDancing(in: entity.scene)
                        }
                    } else {
                        for child in entity.children {
                            child.stopDancing()
                        }
                    }
                }
            }
    }
    
    // MARK: - Initialization
    private func initializeScene() async {
        await preloadEntities()
        loaded = true
    }
    
    private func preloadEntities() async {
        let gemstoneFileNames = allGemstones.map { $0.name }
        
        for name in gemstoneFileNames {
            do {
                let entity = try await Entity(named: name, in: realityKitContentBundle)
                entity.name = name
                addInteractionComponents(to: entity)
                preloaded[name] = entity
            } catch {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        
        if let boardMixer = try? await Entity(named: "BoardMixer", in: realityKitContentBundle) {
            boardMixer.name = "BoardMixer"
            preloaded["BoardMixer"] = boardMixer
        } else {
            print("BoardMixer failed to load")
        }
    }
    
    private func addInteractionComponents(to entity: Entity) {
        var gestures = GestureComponent()
        gestures.canAnimateOnGrab = true
        entity.components.set(gestures)
        entity.components.set(InputTargetComponent())
        entity.components.set(CollisionComponent(
            shapes: [ShapeResource.generateBox(size: [0.3, 0.3, 0.3])],
            mode: .default,
            filter: CollisionFilter(group: .all, mask: .all)
        ))
    }
    
    // MARK: - Element Creation
    private func createProceduralElement(_ element: ChemicalElement) -> Entity {
        let entity = Entity()
        entity.name = element.symbol
        
        let sphereEntity = Entity()
        let sphere = MeshResource.generateSphere(radius: 0.1)
        let material = SimpleMaterial(color: getElementColor(element), isMetallic: true)
        sphereEntity.components.set(ModelComponent(mesh: sphere, materials: [material]))
        sphereEntity.name = "sphereEntity"
        entity.addChild(sphereEntity)
        
        let textMesh = MeshResource.generateText(
            element.symbol,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1, weight: .bold)
        )
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = Entity()
        textEntity.components.set(ModelComponent(mesh: textMesh, materials: [textMaterial]))
        textEntity.name = "textEntity"
        
        let bounds = textEntity.visualBounds(relativeTo: nil)
        let centerX = (bounds.max.x + bounds.min.x) / 2
        textEntity.position = SIMD3<Float>(-centerX, 0, 0)
        
        let textParent = Entity()
        textParent.addChild(textEntity)
        textParent.position = SIMD3<Float>(0, 0.15, 0)
        textParent.name = "textParent"
        entity.addChild(textParent)
        
        addInteractionComponents(to: entity)
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateSphere(radius: 0.1)],
            mode: .default,
            filter: CollisionFilter(group: .all, mask: .all)
        )
        
        return entity
    }
    
    private func handleDroppedElement(_ items: [DraggableElement]) -> Bool {
        guard let element = items.first,
              let chemElement = chemicalElements.first(where: { $0.symbol == element.symbol }) else {
            return false
        }
        
        appModel.addElement(chemElement)
        return true
    }
}

#Preview {
    ImmersiveView()
}
