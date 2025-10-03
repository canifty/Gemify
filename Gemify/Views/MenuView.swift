//
//  MenuView.swift
//  Gemify
//
//  Created by Can Dindar on 02/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct MenuView: View {
    let elements: [Elements]
    
    let columns = Array(repeating: GridItem(.fixed(120), spacing: 20), count: 3)
    
    var body: some View {
        
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(elements) { element in
                Button {
                    print("\(element.name)")
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(element.atomicNumber)")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text(element.symbol)
                                .font(.caption2)
                                .bold()
                        }
                        RealityView { content in
//                            change name with the element.name 
                            if let entity = try? await Entity(named: "Diamondtest", in: realityKitContentBundle) {
                                entity.scale = SIMD3<Float>(repeating: 0.1)
                                content.add(entity)
                            }
                        }
                        Text(element.name)
                            .font(.caption2)
                    }
                    .padding()
//                    .frame(width: 120, height: 120)
                    .cornerRadius(10)
                    .glassBackgroundEffect()
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
//        .background(.ultraThickMaterial)
    }
}

#Preview {
    MenuView(elements: elements)
    
}
