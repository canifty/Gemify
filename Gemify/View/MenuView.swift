//
//  MenuView.swift
//  Gemify
//
//  Created by Gizem Coskun on 02/10/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct MenuView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow

    @State private var selectedCategory = "gems"

    var filteredModels: [Model3D] {
        allModels.filter { $0.category == selectedCategory }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                SegmentedControlView(selection: $selectedCategory)
                    .padding(.horizontal)
            }

            Divider()

            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(filteredModels) { model in
                        MenuModelView(
                            modelName: model.fileName,
                            displayName: model.displayName,
                            onAdd: {
                                appModel.addModel(model.fileName)
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }

                    if filteredModels.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "cube.transparent")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("No \(selectedCategory) available")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 300)
                    }
                }
                .padding()
                .animation(
                    .spring(response: 0.3, dampingFraction: 0.7),
                    value: selectedCategory
                )
            }
        }
    }
}
