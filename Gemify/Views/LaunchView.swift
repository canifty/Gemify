//
//  LaunchView.swift
//  Gemify
//
//  Created by Can Dindar on 30/09/25.
//

import SwiftUI

struct LaunchView: View {
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var isImmersiveSpaceOpen: Bool = false
    
    var body: some View {
        Button(isImmersiveSpaceOpen ? "Close Immersion" : "Open Immersion") {
            Task {
                if isImmersiveSpaceOpen {
                    await dismissImmersiveSpace()
                    isImmersiveSpaceOpen = false
                } else {
                    let result = await openImmersiveSpace(id: "Immersive")
                    switch result {
                    case .opened:
                        isImmersiveSpaceOpen = true
                    case .userCancelled, .error:
                        isImmersiveSpaceOpen = false
                    @unknown default:
                        isImmersiveSpaceOpen = false
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchView()
}
