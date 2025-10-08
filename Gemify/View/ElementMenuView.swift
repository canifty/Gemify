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
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let symbolSize = size * 0.4
                
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.15)
                        .fill(Color.secondary.opacity(0.5))
                    
                    VStack(spacing: size * 0.08) {
                        Text(element.symbol)
                            .font(.system(size: symbolSize, weight: .bold))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        
                        Text(element.name)
                            .font(.system(size: size * 0.12))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                    }
                    
                    VStack {
                        HStack {
                            Text("\(element.atomicNumber)")
                                .font(.system(size: size * 0.10))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .foregroundStyle(.white)
                                .padding(.leading, size * 0.08)
                                .padding(.top, size * 0.08)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
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
