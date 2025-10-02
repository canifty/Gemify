import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Load and add Cone
            if let cone = try? await Entity(named: "Cone", in: realityKitContentBundle) {
                cone.components.set(GestureComponent())
                cone.components.set(InputTargetComponent())
                let meshBounds = cone.visualBounds(relativeTo: nil)
                let size = meshBounds.extents // actual mesh size
                cone.components.set(CollisionComponent(
                    shapes: [ShapeResource.generateBox(size: size)]
                ))
                content.add(cone)
            } else {
                print("Cone not found!!")
            }

            // Load and add Diamond
            if let diamond = try? await Entity(named: "Diamondtest", in: realityKitContentBundle) {
                diamond.components.set(GestureComponent())
                diamond.components.set(InputTargetComponent())
                let meshBounds = diamond.visualBounds(relativeTo: nil)
                let size = meshBounds.extents // actual mesh size
                diamond.components.set(CollisionComponent(
                    shapes: [ShapeResource.generateBox(size: size)]
                ))
                content.add(diamond)
            } else {
                print("Diamond not found!!")
            }
        }
        update: { content in
            
        }
        .installGestures()
    }
}

#Preview {
    ImmersiveView()
}
