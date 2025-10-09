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
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.15)
                    .fill(Color.secondary.opacity(0.5))
                VStack {
                    RealityView { content in
                        do {
                            let scene = try await Entity(named: gem.name, in: realityKitContentBundle)
                            scene.scale = SIMD3<Float>(repeating: Float(size / 400))
                            scene.position = [0, 0, 0.02]
                            content.add(scene)
                        } catch { print(error) }
                    }
                    .frame(width: size * 0.7, height: size * 0.7)
                    
                    Text(gem.name)
                        .font(.system(size: size * 0.12, weight: .semibold))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .frame(width: size, height: size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
