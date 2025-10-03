//
//  Model3D.swift
//  Gemify
//
//  Created by Gizem Coskun on 03/10/25.
//

import Foundation

struct Model3D: Identifiable {
    let id = UUID()
    let fileName: String
    let displayName: String
    let category: String
}

let allModels = [
    // GEMS
    Model3D(fileName: "Diamondtest", displayName: "Diamond", category: "gems"),
    Model3D(fileName: "Gizem", displayName: "Gizem", category: "gems"),
    
    // ELEMENTS
    Model3D(fileName: "Panchito", displayName: "Panchito", category: "elements")
]
