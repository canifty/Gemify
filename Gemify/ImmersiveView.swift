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
    // MARK: - State Properties
    @State private var preloaded: [String: Entity] = [:]
    @State private var loaded = false
    
    @State private var elementEntities: [String: Entity] = [:]
    @State private var gemEntities: [UUID: Entity] = [:]
    
    @State private var modelsContainer: Entity?
    @State private var hasOpenedMenu = false
    
    // MARK: - Environment
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    
    // MARK: - Constants
    private let cubeDetectionStep: Float = 0.25
    private let cubeDetectionRadius: Float = 0.02
    private let cubeXRange: ClosedRange<Float> = -0.5...0.5
    private let cubeYRange: ClosedRange<Float> = 0.0...1.0
    private let cubeZRange: ClosedRange<Float> = -3.0...(-2.0)
    private let gemScale: Float = 1.0
    
    var body: some View {
        RealityView { content in
            setupInitialScene(content: content)
        } update: { content in
            guard loaded else { return }
            updateScene(content: content)
        }
        .installGestures()
        .dropDestination(for: DraggableElement.self) { items, location in
            handleDroppedElement(items)
        }
        .task {
            await initializeScene()
        }
    
        debugButtons
    }
    
    // MARK: - UI Components
    private var debugButtons: some View {
        VStack(spacing: 16) {
            Button("Check Recipe") {
                checkRecipe()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    // MARK: - Scene Setup
    private func setupInitialScene(content: RealityViewContent) {
        let container = Entity()
        container.name = "ModelsContainer"
        content.add(container)
        
        Task { @MainActor in
            modelsContainer = container
        }
        
        createCubeVisualization(content: content)
    }
    
    private func createCubeVisualization(content: RealityViewContent) {
        for x in stride(from: cubeXRange.lowerBound, through: cubeXRange.upperBound, by: cubeDetectionStep) {
            for y in stride(from: cubeYRange.lowerBound, through: cubeYRange.upperBound, by: cubeDetectionStep) {
                for z in stride(from: cubeZRange.lowerBound, through: cubeZRange.upperBound, by: cubeDetectionStep) {
                    
                    let isOnXFace = (x == cubeXRange.lowerBound || x == cubeXRange.upperBound)
                    let isOnYFace = (y == cubeYRange.lowerBound || y == cubeYRange.upperBound)
                    let isOnZFace = (z == cubeZRange.lowerBound || z == cubeZRange.upperBound)
                    
                    let facesCount = [isOnXFace, isOnYFace, isOnZFace].filter { $0 }.count
                    
                    if facesCount >= 2 {
                        let sphere = ModelEntity(
                            mesh: .generateSphere(radius: cubeDetectionRadius),
                            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
                        )
                        sphere.position = [x, y, z]
                        content.add(sphere)
                    }
                }
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
            
            // Don't remove gems! Only remove if it's not a gem AND not in current IDs
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
        elementEntity.position = model.position
        elementEntity.components.set(ModelIDComponent(id: model.id))
        container.addChild(elementEntity)
        
        let uniqueKey = "\(element.symbol)_\(model.id)"
        elementEntities[uniqueKey] = elementEntity
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            checkRecipe()
        }
    }
    
    private func add3DModel(_ model: DroppedModel, to container: Entity) async {
        do {
            let scene = try await Entity(named: model.modelName, in: realityKitContentBundle)
            scene.position = model.position
            scene.scale = SIMD3<Float>(repeating: 1.0)
            scene.name = model.modelName
            
            scene.components.set(GestureComponent())
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
            print("Error loading \(model.modelName): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Recipe & Gem Creation
    private func checkRecipe() {
        let insideElements = getElementsInsideCube()
        
        print("Elements in cube: \(insideElements)")
        
        guard !insideElements.isEmpty else {
            print("No elements in cube")
            return
        }
        
        let elements = insideElements.compactMap { Element(symbol: $0) }
        let elementSet = Set(elements)
        
        print("Element Set: \(elementSet.map { $0.symbol })")
        
        if let matchedGemstone = findMatchingGemstone(for: elementSet) {
            print("RECIPE MATCH: \(matchedGemstone.name)")
            createGemIfNeeded(matchedGemstone, elements: elements)
        } else {
            print("No recipe matched")
        }
    }
    
    private func getElementsInsideCube() -> [String] {
        elementEntities
            .filter { key, entity in
                let symbol = key.components(separatedBy: "_").first ?? key
                let isElement = symbol.count <= 2 && symbol.first?.isUppercase == true
                
                // Make sure it's not a gem
                guard let idComponent = entity.components[ModelIDComponent.self] else {
                    return false
                }
                let isGem = gemEntities.keys.contains(idComponent.id)
                
                let isInside = isInsideCube(entity.position(relativeTo: nil))
                
                if isElement && !isGem && isInside {
                    print("  ✅ \(symbol) in cube")
                }
                
                return isElement && !isGem && isInside
            }
            .map { key, _ in
                key.components(separatedBy: "_").first ?? key
            }
    }
    
    private func findMatchingGemstone(for elementSet: Set<Element>) -> Gemstone? {
        allGemstones.first { $0.recipe == elementSet }
    }
    
    private func createGemIfNeeded(_ gemstone: Gemstone, elements: [Element]) {
        print("💎 Creating gem: \(gemstone.modelFileName)")
        
        removeElements(elements)
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            createGemEntity(gemFileName: gemstone.modelFileName)
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
                print("Removing element: \(uniqueKey)")
                
                if let idComponent = entity.components[ModelIDComponent.self] {
                    print("   → Removing from AppModel with ID: \(idComponent.id)")
                    appModel.removeModel(id: idComponent.id)
                }
                
                entity.removeFromParent()
                
                elementEntities.removeValue(forKey: uniqueKey)
                
            }
        }
        
    }
    
    private func createGemEntity(gemFileName: String) {
        print("Creating gem entity: \(gemFileName)")
        
        guard let container = modelsContainer else {
            print("Container is nil")
            return
        }
        
        guard let gemEntity = preloaded[gemFileName] else {
            print("Gem not preloaded: \(gemFileName)")
            print("Available preloaded gems: \(preloaded.keys.sorted())")
            return
        }
        
        let gemPosition = calculateCubeCenter()
        let gemId = UUID()
        
        let clone = gemEntity.clone(recursive: true)
        clone.name = gemFileName
        clone.position = gemPosition
        clone.scale = SIMD3<Float>(repeating: gemScale)
        clone.components.set(ModelIDComponent(id: gemId))
        
        container.addChild(clone)
        
        gemEntities[gemId] = clone
        
        elementEntities["\(gemFileName)_\(gemId)"] = clone
        
        print("Gem added at \(gemPosition)!")
        print("Total gems: \(gemEntities.count)")
    }
    
    private func calculateCubeCenter() -> SIMD3<Float> {
        SIMD3<Float>(
            (cubeXRange.lowerBound + cubeXRange.upperBound) / 2,
            (cubeYRange.lowerBound + cubeYRange.upperBound) / 2,
            (cubeZRange.lowerBound + cubeZRange.upperBound) / 2
        )
    }
    
    // MARK: - Initialization
    private func initializeScene() async {
        await preloadEntities()
        loaded = true
        
        if !hasOpenedMenu {
            hasOpenedMenu = true
            openWindow(id: "MenuWindow")
        }
    }
    
    private func preloadEntities() async {
        print("\n Starting preload...")
        
        // Use the modelFileNames from allGemstones instead of hardcoded array
        let gemstoneFileNames = allGemstones.map { $0.modelFileName }
        
        for name in gemstoneFileNames {
            do {
                let entity = try await Entity(named: name, in: realityKitContentBundle)
                entity.name = name
                addInteractionComponents(to: entity)
                preloaded[name] = entity
                print("\(name)")
            } catch {
                print("\(name) failed to load: \(error.localizedDescription)")
            }
        }
        
        print("Preload complete\n")
    }
    
    private func addInteractionComponents(to entity: Entity) {
        entity.components.set(GestureComponent())
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
        
        let sphere = MeshResource.generateSphere(radius: 0.1)
        let material = SimpleMaterial(color: getElementColor(element), isMetallic: true)
        entity.components.set(ModelComponent(mesh: sphere, materials: [material]))
        
        let textEntity = createTextLabel(for: element)
        entity.addChild(textEntity)
        
        addInteractionComponents(to: entity)
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateSphere(radius: 0.1)],
            mode: .default,
            filter: CollisionFilter(group: .all, mask: .all)
        )
        
        return entity
    }
    
    private func createTextLabel(for element: ChemicalElement) -> Entity {
        let textMesh = MeshResource.generateText(
            element.symbol,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1, weight: .bold)
        )
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = Entity()
        textEntity.components.set(ModelComponent(mesh: textMesh, materials: [textMaterial]))
        textEntity.position = SIMD3<Float>(0, 0.15, 0)
        return textEntity
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
    
    // MARK: - Helper Functions
    private func isInsideCube(_ position: SIMD3<Float>) -> Bool {
        cubeXRange.contains(position.x) &&
        cubeYRange.contains(position.y) &&
        cubeZRange.contains(position.z)
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
