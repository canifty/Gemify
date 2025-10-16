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
        Group {
            if !OnboardingManager.shouldOnboardingDisplay() {
                LaunchView()
                    .glassBackgroundEffect()
            } else {
                VStack {
                    TabView(selection: $currentPage) {
                        LaunchView(isShowingButton: shouldStartAppear)
                            .tag(0)
                        
                        PageView(
                            title: "ELEMENTS",
                            context: "On your element menu you can find selection of atoms ready to be combined. \n\nEach one carries unique energy and potential. \n\nChoose wisely: the right combinations leads to precious creations.",
                            image: "ElementsMenuAsset",
                            currentPage: $currentPage,
                            showOnboarding: $showOnboarding,
                            totalPages: totalPages
                        )
                        .tag(1)
                        .padding()
                        PageView(
                            title: "INTERACTIONS",
                            context: "This is your workspace. \n\nPick up the atoms and place them on the fusion platform. \n\nWhen you’re ready, tap on the lever and witness atoms merge into something brilliant — a new gem.",
                            image: "TableLever",
                            currentPage: $currentPage,
                            showOnboarding: $showOnboarding,
                            totalPages: totalPages
                        )
                        .tag(2)
                        .padding()

                        PageView(
                            title: "GEMS",
                            context: "Each successful combination reveals a new gem and adds it to your collection.  \n\nDiscover what you’ve already forged — and what’s still waiting to be uncovered. \n\nComplete your gem table and master the art of creation.",
                            image: "ElementsMenuAsset",
                            currentPage: $currentPage,
                            showOnboarding: $showOnboarding,
                            totalPages: totalPages
                        )
                        .tag(3)
                        .padding()

                        PageView(
                            title: "GESTURES",
                            context: "\n\nPinch & Drag: move or reposition gems in space. \n\nRotate: examine every facet from all angles.\n\nZoom: get closer to admire the fine details.",
                            image: "Gestures",
                            currentPage: $currentPage,
                            showOnboarding: $showOnboarding,
                            totalPages: totalPages
                        )
                        .tag(4)
                        .padding()

                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

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
                .padding(.bottom)
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
        VStack(alignment: .leading) {
            Text(title)
                .italic()
                .font(.largeTitle)
                .bold()
            HStack(spacing: 20) {
                
                Text(context)
                    .font(.system(size: 18))
                    .bold()
                
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.top)
            }
            .padding(.leading)
        }
        .padding()
    }
}
#Preview {
    OnboardingView()
        .frame(maxWidth: 600, maxHeight: 440)
}
