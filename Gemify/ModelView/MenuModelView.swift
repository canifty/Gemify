//
//  MenuModelView.swift
//  Gemify
//
//  Created by Gizem Coskun on 02/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

// MARK: - Menu Model View
struct MenuModelView: View {
    let modelName: String
    let displayName: String
    let onAdd: () -> Void
    
    var body: some View {
        VStack {
            RealityView { content in
                do {
                    let scene = try await Entity(named: modelName, in: realityKitContentBundle)
                    scene.scale = SIMD3<Float>(repeating: 0.3)
                    content.add(scene)
                } catch {
                    print("Error loading \(modelName): \(error.localizedDescription)")
                }
            }
            .frame(width: 200, height: 200)
            .frame(depth: 200)
            
            Text(displayName)
                .font(.headline)
            Button {
                onAdd()
            } label: {
                Label("Add to Space", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    MenuView()
        .environment(AppModel())
}

