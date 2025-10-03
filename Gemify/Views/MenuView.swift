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
                        print(element.name)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(element.atomicNumber)")
                                .font(.caption)
                            
                            Text(element.symbol)
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                            
                            Text(element.name)
                                .font(.caption2)
                        }
                        .padding()
                        .frame(width: 120)
                        .cornerRadius(10)
                        .glassBackgroundEffect()
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(.ultraThickMaterial)
            .padding()
    }
}

#Preview(windowStyle: .plain) {
    MenuView(elements: elements)
    
}
