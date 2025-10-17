//
//  OnboardingGesture.swift
//  Gemify
//
//  Created by Can Dindar on 16/10/25.
//

import SwiftUI

struct OnboardingGesture: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            
            VStack(alignment: .leading, spacing: 24) {
                Text("GESTURES")
                    .bold()
                    .italic()
                    .font(.system(size: width * 0.05, weight: .bold))
                    .padding(.leading, 32)
                
                VStack(alignment: .center, spacing: 10) {
                    GestureRow(
                        text: "Pinch & Drag: move or reposition gems in space.",
                        imageName: "pinch",
                        width: width
                    )
                    GestureRow(
                        text: "Rotate: examine every facet from all angles.",
                        imageName: "rotate",
                        width: width
                    )
                    GestureRow(
                        text: "Zoom: get closer to admire the fine details.",
                        imageName: "zoom",
                        width: width
                    )
                }
                .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct GestureRow: View {
    let text: String
    let imageName: String
    let width: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Spacer()
            Text(text)
                .font(.system(size: width * 0.02))
                .bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: width * 0.5, alignment: .leading)
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.15)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    OnboardingGesture()
        .glassBackgroundEffect()
        .padding()
}
