//
//  GemifyApp.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

@main
struct GemsApp: App {
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    @State private var appModel = AppModel()
    
    var body: some SwiftUI.Scene {
        
        WindowGroup(id: "Onboarding") {
//            LaunchView()
            OnboardingView()
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        WindowGroup(id: "MenuWindow") {
            MenuView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 400, height: 600)
    }
}
