//
//  SharedAppModel.swift
//  Gemify
//
//  Created by Gizem Coskun on 02/10/25.
//

import SwiftUI
import RealityKit


// MARK: - Supporting Types
struct DroppedModel: Identifiable {
    let id = UUID()
    var modelName: String
    var position: SIMD3<Float>
}

struct ModelIDComponent: Component {
    let id: UUID
}


// MARK: - Shared App Model
@Observable
class AppModel {
    var droppedModels: [DroppedModel] = []
    
    func addModel(_ modelName: String) {
        let newModel = DroppedModel(
            modelName: modelName,
            position: SIMD3<Float>(0, 1.5, -1.5)
        )
        droppedModels.append(newModel)
        print("✅ Added \(modelName) to models array")
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

