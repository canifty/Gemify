//
//  ElementMenuView.swift
//  Gemify
//
//  Created by Gizem Coskun on 03/10/25.
//


import SwiftUI
import RealityKit

struct ElementMenuView: View {
    let element: ChemicalElement
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(elementColor.opacity(0.2))
                VStack(spacing: 4) {
                    Text("\(element.atomicNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(element.symbol)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(elementColor)
                    
                    Text(element.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                onAdd()
            } label: {
                Label("Add", systemImage: "plus.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
        }
        .draggable(element.toDraggable())
    }
    
    private var elementColor: Color {
        switch element.symbol {
        case "H": return .red
        case "Li", "Na", "Ca": return .purple
        case "Be", "Mg", "Al": return .blue
        case "B", "C", "Si": return .brown
        case "O", "F": return .green
        case "P": return .orange
        case "Cu", "Zr": return .cyan
        default: return .gray
        }
    }
}
