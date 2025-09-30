//
//  GemifyApp.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import SwiftUI

@main
struct GemifyApp: App {
    @State private var selectedImmersionStyle: ImmersionStyle = .progressive
    
    var body: some Scene {
        
        WindowGroup {
            LaunchView()
        }
        
        ImmersiveSpace(id: "CubeImmersive") {
            CubeImmersiveView()
        }
        .immersionStyle(selection: $selectedImmersionStyle,
                        in: .mixed, .progressive, .full)
    }
}
