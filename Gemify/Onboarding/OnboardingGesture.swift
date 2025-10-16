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
        VStack(alignment: .leading) {
            Text("GESTURES")
                .bold()
                .italic()
                .font(.system(size: width * 0.05, weight: .bold))
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10){
                    Spacer()
                    Text("Pinch & Drag: move or reposition gems in space.")
                        .font(.system(size: width * 0.02))
                        .bold()
                        .frame(maxWidth: width * 0.4, alignment: .leading)
                    Spacer()
                    Image("pinch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.12)
                    Spacer()
                }
                HStack(spacing: 10){
                    Spacer()

                    Text("Rotate: examine every facet from all angles.")
                        .font(.system(size: width * 0.02))
                        .bold()
                        .frame(maxWidth: width * 0.4, alignment: .leading)
                    Spacer()
                    Image("rotate")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.20)
                    Spacer()
                }
                HStack(spacing: 10){
                    Spacer()

                    Text("Zoom: get closer to admire the fine details.")
                        .font(.system(size: width * 0.02))
                        .bold()
                        .frame(maxWidth: width * 0.4, alignment: .leading)
                    Spacer()
                    Image("zoom")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.20)
                    Spacer()
                }
            }
            .padding()
        }
        .padding()
    }
}
}

#Preview {
    OnboardingGesture()
        .glassBackgroundEffect()
        .padding()
}
