//
//  CubeImmersiveView.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct CubeImmersiveView: View {

    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Cube", in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in

        }
    }
}

#Preview("Immersive Style", immersionStyle: .automatic, body: {
    CubeImmersiveView()
})
