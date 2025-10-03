//
//  MenuView.swift
//  Gemify
//
//  Created by Gizem Coskun on 02/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct MenuView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Objects Menu")
                    .font(.title2)
                    .padding(.top)
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
                        modelName: "Panchito",
                        displayName: "Panchito",
                        onAdd: {
                            appModel.addModel("Panchito")
                        }
                    )
                    
                    MenuModelView(
                        modelName: "Gizem",
                        displayName: "Gizem",
                        onAdd: {
                            appModel.addModel("Gizem")
                        }
                    )
                }
                .padding()
            }
        }
    }
}
