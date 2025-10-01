//
//  CubeImmersiveView.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
        
    var body: some View {
        RealityView { content in
            if let cube = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(cube)
            }
        }
        update: { content in
            
        }
        .installGestures()
    }
}

#Preview {
    ImmersiveView()
}
