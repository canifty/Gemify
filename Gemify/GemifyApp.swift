//
//  GemifyApp.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import SwiftUI
import RealityKitContent

@main
struct GemifyApp: App {
    @State private var selectedImmersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        
        ImmersiveSpace {
            CubeImmersiveView()
        }
//        ImmersiveSpace(id: "CubeImmersive") {
//            CubeImmersiveView()
//        }
//        .immersionStyle(selection: $selectedImmersionStyle,
//                        in: .mixed)
    }
}
