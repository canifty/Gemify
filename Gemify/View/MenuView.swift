//
//  MenuView.swift
//  Gemify
//
//  Created by Gizem Coskun on 02/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

// MARK: - Menu Window View
struct MenuView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isImmersiveSpaceOpen = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Objects Menu")
                    .font(.title2)
                    .padding(.top)
                
                Toggle(isOn: $isImmersiveSpaceOpen) {
                    Label(
                        isImmersiveSpaceOpen ? "Close Drop Zone" : "Open Drop Zone",
                        systemImage: isImmersiveSpaceOpen ? "eye.slash" : "eye"
                    )
                }
                .toggleStyle(.button)
                .padding()
                .onChange(of: isImmersiveSpaceOpen) { _, newValue in
                    print("🔄 Toggle changed to: \(newValue)")
                    Task {
                        if newValue {
                            print("🚀 Opening immersive space...")
                            await openImmersiveSpace(id: "DropZone")
                            print("✅ Immersive space opened")
                        } else {
                            print("🚪 Closing immersive space...")
                            await dismissImmersiveSpace()
                            print("✅ Immersive space closed")
                        }
                    }
                }
            }
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    MenuModelView(
                        modelName: "Diamondtest",
                        displayName: "Diamond",
                        onAdd: {
                            appModel.addModel("Diamondtest")
                        }
                    )
                    
                    MenuModelView(
                        modelName: "Diamondtest",
                        displayName: "Diamond",
                        onAdd: {
                            appModel.addModel("Diamondtest")
                        }
                    )
                   
                }
                .padding()
            }
        }
    }
}
