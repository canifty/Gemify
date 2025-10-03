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
        
    @State private var appModel = AppModel()
    
    init() {
        RealityKitContent.GestureComponent.registerComponent()
    }
    
    var body: some SwiftUI.Scene {
        
        WindowGroup(id: "MenuView") {
            MenuView(elements: elements)
        }
        .defaultSize(width: 500, height: 600)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
