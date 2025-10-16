//
//  OnboardingGesture.swift
//  Gemify
//
//  Created by Can Dindar on 16/10/25.
//

import SwiftUI

struct OnboardingGesture: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("GESTURES")
                .bold()
                .italic()
                .font(.extraLargeTitle)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10){
                    Text("Pinch & Drag: move or reposition gems in space.")
                    Spacer()

                    Image("pinch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
                HStack(spacing: 10){
                    Text("Rotate: examine every facet from all angles.")
                    Spacer()

                    Image("rotate")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                }
                HStack(spacing: 10){

                    Text("Zoom: get closer to admire the fine details.")
                    Spacer()

                    Image("zoom")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    OnboardingGesture()
        .glassBackgroundEffect()
        .padding()
}
