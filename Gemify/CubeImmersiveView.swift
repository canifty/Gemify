//
//  CubeImmersiveView.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//


import SwiftUI
import RealityKit

struct CubeImmersiveView: View {
    @State private var rotation: Double = 0
    

    var body: some View {
        RealityView { content in
            let anchor = AnchorEntity()
            if let cube = try? await ModelEntity(named: "Cube") {
                let numberOfCubes = 8
                for index in 0..<numberOfCubes {
                    let angle = Float(index) * (2 * .pi / Float(numberOfCubes))
                    let xPosition = cos(angle)
                    let zPosition = sin(angle)
                    let cubeEntity = cube.clone(recursive: false)
                    cubeEntity.position = [xPosition, 1.5, zPosition]
                    cubeEntity.generateCollisionShapes(recursive: false)
                    cubeEntity.components.set(InputTargetComponent())
                    anchor.addChild(cubeEntity)
                }
            }
            content.add(anchor)
        } update: { content in
            if let anchor = content.entities.first {
                anchor.transform.rotation = simd_quatf(angle: Float(rotation) * .pi / 180, axis: [0, 1, 0])
                for entity in anchor.children {
                    entity.transform.rotation = simd_quatf(
                        Rotation3D(angle: Angle2D(degrees: rotation), axis: .xyz)
                    )
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    rotation += value.translation.width/100
                }
                .targetedToAnyEntity()
        )
    }
}

#Preview(windowStyle: .automatic) {
    CubeImmersiveView()
        
}
