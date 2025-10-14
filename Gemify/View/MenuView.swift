//
//  MenuView.swift
//  Gemify
//
//  Created by Gizem Coskun on 02/10/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

//struct MenuView: View {
//    @Environment(AppModel.self) private var appModel
//    @Environment(\.openWindow) private var openWindow
//    
//    @State private var selectedCategory = "elements"
//    
//    var filteredModels: [Model3D] {
//        allModels.filter { $0.category == selectedCategory }
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            
//            ScrollView {
//                
//                SegmentedControlView(selection: $selectedCategory)
//                    .padding(.horizontal)
//                
//                LazyVGrid(
//                    columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),
//                    spacing: 20
//                ) {
//                    ForEach(filteredModels) { model in
//                        MenuModelView(
//                            modelName: model.fileName,
//                            displayName: model.displayName,
//                            onAdd: {
//                                appModel.addModel(model.fileName)
//                            }
//                        )
//                        .transition(.scale.combined(with: .opacity))
//                    }
//                    
//                    if filteredModels.isEmpty {
//                        VStack(spacing: 12) {
//                            Image(systemName: "cube.transparent")
//                                .font(.system(size: 60))
//                                .foregroundColor(.secondary)
//                            Text("No \(selectedCategory) available")
//                                .font(.headline)
//                                .foregroundColor(.secondary)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .gridCellColumns(3).frame(maxWidth: .infinity)
//                        .gridCellColumns(3)
//                    }
//                }
//                .padding()
//                .animation(
//                    .spring(response: 0.3, dampingFraction: 0.7),
//                    value: selectedCategory
//                )
//            }
//            
//        }
//        .padding()
//        .glassBackgroundEffect()
//        .cornerRadius(50)
//    }
//}


import SwiftUI
import RealityKit
import RealityKitContent

struct MenuView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    
    @State private var selectedCategory = "elements"
    
    var filteredModels: [Model3D] {
        allModels.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                SegmentedControlView(selection: $selectedCategory)
                    .padding(.horizontal)
                
                if selectedCategory == "elements" {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),
                        spacing: 20
                    ) {
                        ForEach(chemicalElements) { element in
                            ElementMenuView(
                                element: element,
                                onAdd: {
                                    appModel.addElement(element)
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                } else if selectedCategory == "gems" {
                    VStack {
                        Text("Unlocked Gems: \(appModel.discoveredGemstones.count)/\(allGemstones.count)")
                            .padding()
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),
                            spacing: 20
                        ) {
                            ForEach(allGemstones) { gem in
                                GemstoneMenuView(
                                    gem: gem,
                                    isLocked: !appModel.discoveredGemstones.contains(where:{ $0.id == gem.id})
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                    }
                }
            }
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: selectedCategory
            )
        }
        .padding()
        .glassBackgroundEffect()
        .cornerRadius(50)
    }
}
