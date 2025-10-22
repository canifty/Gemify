import SwiftUI
import RealityKit
import RealityKitContent

struct MenuView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var showRestartAlert = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),
                        spacing: 20
                    ) {
                        ForEach(chemicalElements) { element in
                            ElementMenuView(
                                element: element,
                                onAdd: {
                                    appModel.addElement(element)
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                }
                .tabItem {
                    Label("Elements", systemImage: "square.grid.3x3")
                }
                .tag(0)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Unlocked Gems: \(appModel.discoveredGemstones.count)/\(allGemstones.count)")
                            .bold()
                            .padding()
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),
                            spacing: 20
                        ) {
                            ForEach(allGemstones) { gem in
                                GemstoneMenuView(
                                    gem: gem,
                                    isLocked: !appModel.discoveredGemstones.contains(where: { $0.id == gem.id })
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                    }
                }
                .tabItem {
                    Label("Gems", systemImage: "diamond")
                }
                .tag(1)
            }
            .toolbar {
                Button {
                    appModel.deleteEverything.toggle()
                } label: {
                    Label("Clean the Elements", systemImage: "arrow.trianglehead.clockwise")
                }
                
                Button {
                    showRestartAlert = true
                } label: {
                    Label("Open Immersive", systemImage: "pano")
                }
            }
            .navigationTitle(selectedTab == 0 ? "Elements" : "Gems")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
