//
//  ImmersiveView+PositionDetection.swift
//  Gemify
//
//  Created by Francisco Mestizo on 14/10/25.
//

import Foundation
import RealityKit

extension ImmersiveView {
    func calculateCubeCenter(xRange: ClosedRange<Float>, yRange: ClosedRange<Float>, zRange: ClosedRange<Float>) -> SIMD3<Float> {
        SIMD3<Float>(
            (xRange.lowerBound + xRange.upperBound) / 2,
            (yRange.lowerBound + yRange.upperBound) / 2,
            (zRange.lowerBound + zRange.upperBound) / 2
        )
    }
    
    func getElementsInsideCube(elementEntities: [String: Entity], gemEntities: [UUID: Entity], xRange: ClosedRange<Float>, yRange: ClosedRange<Float>, zRange: ClosedRange<Float>) -> [String] {
        elementEntities
            .filter { key, entity in
                let symbol = key.components(separatedBy: "_").first ?? key
                let isElement = symbol.count <= 2 && symbol.first?.isUppercase == true
                
                guard let idComponent = entity.components[ModelIDComponent.self] else {
                    return false
                }
                let isGem = gemEntities.keys.contains(idComponent.id)
                
                let isInside = isInsideCube(entity.position(relativeTo: nil), xRange: xRange, yRange: yRange, zRange: zRange)
                
                if isElement && !isGem && isInside {
                    print("\(symbol) in cube")
                }
                
                return isElement && !isGem && isInside
            }
            .map { key, _ in
                key.components(separatedBy: "_").first ?? key
            }
    }
    
    func isInsideCube(_ position: SIMD3<Float>, xRange: ClosedRange<Float>, yRange: ClosedRange<Float>, zRange: ClosedRange<Float>) -> Bool {
        xRange.contains(position.x) &&
        yRange.contains(position.y) &&
        zRange.contains(position.z)
    }
}
