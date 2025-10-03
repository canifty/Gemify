//
//  GemifyApp.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import RealityKit
import RealityKitContent
import SwiftUI


//@main
//struct GemifyApp: App {
//    @State private var selectedImmersionStyle: ImmersionStyle = .mixed
//
//    init() {
//        RealityKitContent.GestureComponent.registerComponent()
//    }
//    
//    var body: some SwiftUI.Scene {
//        
//        ImmersiveSpace {
//            ImmersiveView()
//        }
//    }
//}


@main
struct GemsApp: App {
    @State private var appModel = AppModel()
    
    var body: some SwiftUI.Scene {
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveSpaceView()
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
