//
//  GemifyApp.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

@main
struct GemifyApp: App {
    @State private var selectedImmersionStyle: ImmersionStyle = .mixed

    init() {
        RealityKitContent.GestureComponent.registerComponent()
    }
    
    var body: some SwiftUI.Scene {
        
        ImmersiveSpace {
            ImmersiveView()
        }
    }
}
