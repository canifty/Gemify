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
    @State private var diamondEntity: Entity?
    @State private var diamondEntity2: Entity?
    @State private var elementEntities: [String: Entity] = [:]
    
    var body: some View {
        ZStack {
            RealityView { content in
                
                let elements = ["oxygen", "aluminum", "silicon","hydrogen","magnesium", "carbon","beryllium", "calcium"]

                    for (i, name) in elements.enumerated() {
                        if let entity = try? await Entity(named: "Diamondtest", in: realityKitContentBundle) {
                            entity.name = name
                            entity.components.set(GestureComponent())
                            entity.components.set(InputTargetComponent())
                            entity.components.set(CollisionComponent(
                                shapes: [ShapeResource.generateBox(size: [0.1, 0.1, 0.1])],
                                mode: .default,
                                filter: CollisionFilter(group: .all, mask: .all)))
                            
                            
                            entity.position = [Float(i) * 0.3 - 0.5, 1.0, -1.0]
                            
                            content.add(entity)
                            elementEntities[name] = entity
                        }
                    }
                
                /* Create the outline of the box programmatically. The coordinates are
                 
                 x: -0.5 ... 0.5
                 y:  0.0 ... 1.0
                 z: -3.0 ... -2.0
                 
                 */
                
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

            }
            update: { content in

            }
            .installGestures()
            .onAppear {
                
            }
            
            
            Button {
                let insideElements = elementEntities.compactMap { name, entity in
                    return isInsideCube(entity.position) ? name : nil
                }

                print("Inside cube: \(insideElements)")
                
            } label: {
                Text("Get Position")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .buttonStyle(.bordered)
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
