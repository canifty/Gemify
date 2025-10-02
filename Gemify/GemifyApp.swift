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
    @State private var appModel = AppModel()

    init() {
        RealityKitContent.GestureComponent.registerComponent()
    }
    
    var body: some SwiftUI.Scene {
        
        WindowGroup {
            MenuView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 350, height: 600)
        
        ImmersiveSpace {
           ImmersiveView()
        }
    }
}

