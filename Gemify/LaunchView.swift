//
//  LaunchView.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//
import SwiftUI

struct LaunchView: View {
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    var isShowingButton: Bool = true
    
    var body: some View {
        VStack {
            Image("Banner")
                .resizable()
                .scaledToFill()
            VStack {
                Text("Gemify")
                    .font(.extraLargeTitle2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                
                Text("Craft mesmerizing gems by blending mystical elements in a magical space.")
                    .frame(width: 400)
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, -5)
                    .padding(.bottom, 10)
                
                if isShowingButton {
                    Button("Start Building") {
                        Task {
                            await openImmersiveSpace(id: "ImmersiveSpace")
                            dismissWindow(id: "Launch")
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
//        .frame(maxWidth: 600, maxHeight: 440, alignment: .center)
//        .glassBackgroundEffect()
    }
}

#Preview {
    LaunchView()
    
}
