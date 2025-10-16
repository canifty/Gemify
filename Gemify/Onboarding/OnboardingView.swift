//
//  OnboardingView.swift
//  Gemify
//
//  Created by Can Dindar on 14/10/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    @State var showOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var shouldStartAppear: Bool = false
    
    private let totalPages = 5
    
    var body: some View {
        GeometryReader { geo in
            // `geo.size` gives you the current window size
            let width = geo.size.width
            let height = geo.size.height
            if !OnboardingManager.shouldOnboardingDisplay() {
                LaunchView()
                    .glassBackgroundEffect()
            } else {
                VStack {
                    Spacer()
                    switch currentPage {
                    case 0:
                        LaunchView(isShowingButton: shouldStartAppear)
                    case 1:
                        PageView(
                            title: "ELEMENTS",
                            context: "On your element menu you can find selection of atoms ready to be combined. \n\nEach one carries unique energy and potential. \n\nChoose wisely: the right combinations leads to precious creations.",
                            image: "ElementsMenuAsset",
                            currentPage: $currentPage,
                            showOnboarding: $showOnboarding,
                            totalPages: totalPages
                        )
                        .padding()
                    case 2:
                        PageView(
                            title: "INTERACTIONS",
                            context: "This is your workspace. \n\nPick up the atoms and place them on the fusion platform. \n\nWhen you’re ready, tap on the lever and witness atoms merge into something brilliant — a new gem.",
                            image: "TableLever",
                            currentPage: $currentPage,
                            showOnboarding: $showOnboarding,
                            totalPages: totalPages
                        )
                        .padding()
                    case 3:
                        PageView(
                            title: "GEMS",
                            context: "Each successful combination reveals a new gem and adds it to your collection.  \n\nDiscover what you’ve already forged — and what’s still waiting to be uncovered. \n\nComplete your gem table and master the art of creation.",
                            image: "ElementsMenuAsset",
                            currentPage: $currentPage,
                            showOnboarding: $showOnboarding,
                            totalPages: totalPages
                        )
                        .padding()
                    case 4:
                        OnboardingGesture()
                            .padding()
                    default:
                        LaunchView(isShowingButton: !shouldStartAppear)
                    }
                    
                    Spacer()
                    
                    HStack {
                        if currentPage > 0 {
                            Button {
                                currentPage -= 1
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                            }
                            .glassBackgroundEffect()
                        }
                        
                        if currentPage < totalPages - 1 {
                            Button {
                                currentPage += 1
                            } label: {
                                HStack(spacing: 10) {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .glassBackgroundEffect()
                        } else {
                            Button {
                                OnboardingManager.incrementOnboardingCount()
                                showOnboarding = false
                                
                                Task {
                                    await openImmersiveSpace(id: "ImmersiveSpace")
                                    dismissWindow(id: "Onboarding")
                                }
                            } label: {
                                Text("Start Building")
                            }
                            .glassBackgroundEffect()
                        }
                    }
                }
                .frame(width: width, height: height * 0.95)
                .onAppear {
                    shouldStartAppear = !OnboardingManager.shouldOnboardingDisplay()
                }
            }
        }
        .glassBackgroundEffect()
    }
}

struct PageView: View {
    
    let title: String
    let context: String
    let image: String
    
    @Binding var currentPage: Int
    @Binding var showOnboarding: Bool
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    let totalPages: Int
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .italic()
                    .font(.system(size: width * 0.05, weight: .bold))
                    .bold()
                    .padding(.leading, 32)
                HStack(spacing: 20) {
                    Spacer()
                    Text(context)
                        .font(.system(size: width * 0.02))
                        .bold()
                        .frame(maxWidth: width * 0.4, alignment: .leading)
                    Spacer()
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.25)
                    Spacer()
                }
                .padding(.leading)
            }
            .padding()
        }
    }
}

#Preview {
    OnboardingView()
}
