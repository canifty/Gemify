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
    
    var body: some View {
        ZStack {
            RealityView { content in
                
                // Create Diamond 1
                if let entity = try? await Entity(named: "Diamondtest", in: realityKitContentBundle) {
                    
                    entity.name = "DiamondTest"
                    entity.components.set(GestureComponent())
                    entity.components.set(InputTargetComponent())
                    entity.components.set(CollisionComponent(
                        shapes: [ShapeResource.generateBox(size: [0.1, 0.1, 0.1])],
                        mode: .default,
                        filter: CollisionFilter(group: .all, mask: .all)))
                    entity.position = [-0.5,1.0,-1.0]
                    content.add(entity)
                    
                    diamondEntity = entity
                
                } else {
                    print("no object")
                }
                
                // Create Diamond 2
                if let entity2 = try? await Entity(named: "Diamondtest", in: realityKitContentBundle) {
                    
                    entity2.name = "DiamondTest2"
                    entity2.components.set(GestureComponent())
                    entity2.components.set(InputTargetComponent())
                    entity2.components.set(CollisionComponent(
                        shapes: [ShapeResource.generateBox(size: [0.1, 0.1, 0.1])],
                        mode: .default,
                        filter: CollisionFilter(group: .all, mask: .all)))
                    entity2.position = [0.5,1.0,-1.0]
                    content.add(entity2)
                    
                    diamondEntity2 = entity2
                
                } else {
                    print("no object")
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
            
            Button {
                /*
                if let diamond = diamondEntity {
                    print("\(diamond.position)")
                } else {
                    print("cazzo")
                }
                 */
                
                // Detect if both diamonds are inside the box.
                if let diamond = diamondEntity,
                      let diamond2 = diamondEntity2 {
                       
                       let inside1 = isInsideCube(diamond.position)
                       let inside2 = isInsideCube(diamond2.position)
                       
                       if inside1 && inside2 {
                           print("✅ Both diamonds are inside the cube!")
                       } else if inside1 {
                           print("🔴 Only diamond 1 is inside")
                       } else if inside2 {
                           print("🔴 Only diamond 2 is inside")
                       } else {
                           print("❌ Both are outside")
                       }
                       
                   } else {
                       print("One or both diamonds are missing")
                   }
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
