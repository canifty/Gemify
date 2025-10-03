//
//  AppModel.swift
//  Gemify
//
//  Created by Can Dindar on 02/10/25.
//

import RealityKit
import SwiftUI

enum ImmersiveSpaceState {
    case closed
    case inTransition
    case open
}

@Observable
class AppModel {
    
    /// The state of the immersive space, indicating whether the window is closed, backgrounded, or active.
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    /// A Boolean value that indicates whether the cube is in immersive space.
    var cubeInImmersiveSpace = false
}
