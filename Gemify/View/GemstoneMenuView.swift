//
//  GemstoneMenuView.swift
//  Gemify
//
//  Created by Francisco Mestizo on 09/10/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct GemstoneMenuView: View {
    let gem: Gemstone
    var isLocked: Bool = false
    
    var recipeString: String {
        let elementNames = gem.recipe.map { $0.symbol }.sorted().joined(separator: "+ ")
        return elementNames
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.15)
                    .fill(Color.secondary.opacity(isLocked ? 0.3 : 0.5))
                VStack {
                    RealityView { content in
                        do {
                            let scene = try await Entity(named: gem.name, in: realityKitContentBundle)
                            scene.scale = SIMD3<Float>(repeating: Float(size / 400))
                            scene.position = [0, 0, 0.02]
                            content.add(scene)
                        } catch { print(error) }
                  
                    }
                    .frame(width: size * 0.5, height: size * 0.5)
                    .opacity(isLocked ? 0.5 : 1.0)
                    
                    Text(gem.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text(recipeString)
                        .font(.caption2)
                        .fontWeight(.regular)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(width: size, height: size)
                .blur(radius: isLocked ? 2 : 0)
                
                if isLocked {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: size * 0.35, height: size * 0.35)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: size * 0.18))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

