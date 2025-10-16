//
//  SharedAppModel.swift
//  Gemify
//
//  Created by Gizem Coskun on 02/10/25.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers

// MARK: - Supporting Types
struct DroppedModel: Identifiable {
    let id = UUID()
    var modelName: String
    var position: SIMD3<Float>
    var isProceduralElement: Bool = false
    var elementData: ChemicalElement?
}

struct ModelIDComponent: Component {
    let id: UUID
}

struct DraggableElement: Codable, Transferable {
    let symbol: String
    let name: String
    let atomicNumber: Int
    let elementType: String
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .draggableElement)
    }
}

extension UTType {
    static let draggableElement = UTType(exportedAs: "com.yourapp.element")
}

// MARK: - Shared App Model
@Observable
class AppModel {
    var droppedModels: [DroppedModel] = []
    var discoveredGemstones: [Gemstone] = []
    var deleteEverything: Bool = false //this one is used in MenuView and InmersiveView
    
    func addModel(_ modelName: String) {
        let newModel = DroppedModel(
            modelName: modelName,
            position: SIMD3<Float>(0, 1.5, -1.5),
            isProceduralElement: false
        )
        droppedModels.append(newModel)
        print("✅ Added \(modelName) to models array")
    }
    
    func addElement(_ element: ChemicalElement) {
        
        // If the element has already been dropped, the user can't add another one of the same type.
        if droppedModels.contains(where: { $0.elementData?.symbol == element.symbol }) {
                print("⚠️ Element \(element.symbol) already exists in the scene. Only one allowed at a time.")
                return
            }
        
        let newModel = DroppedModel(
            modelName: element.symbol,
            position: SIMD3<Float>(0, 1.5, -1.5),
            isProceduralElement: true,
            elementData: element
        )
        droppedModels.append(newModel)
        print("✅ Added element \(element.symbol) to models array")
    }
    
    // Function to add new gems into the menu
    func discoverGemstone(named gemstoneName: String) {
        // Find the gemstone in your existing master list
        guard let gemstone = allGemstones.first(where: { $0.name == gemstoneName }) else {
            print("⚠️ No gemstone found with name \(gemstoneName)")
            return
        }
        
        // Prevent duplicates
        if !discoveredGemstones.contains(where: { $0.name == gemstone.name }) {
            discoveredGemstones.append(gemstone)
            print("💎 Discovered \(gemstone.name)!")
        }
    }
    
    func updateModelPosition(id: UUID, position: SIMD3<Float>) {
        if let index = droppedModels.firstIndex(where: { $0.id == id }) {
            droppedModels[index].position = position
        }
    }
    
    func removeModel(id: UUID) {
        droppedModels.removeAll { $0.id == id }
    }
}
