//
//  Gemstones.swift
//  Gemify
//
//  Created by Francisco Mestizo on 30/09/25.
//

import Foundation

struct Gemstone: Identifiable {
    let id = UUID()
    let name: String
    let recipe: Set<Element>
    let modelFileName: String
    let category: String = "gemstones"
    
    init(name: String, recipe: Set<Element>, modelFileName: String? = nil) {
        self.name = name
        self.recipe = recipe
        self.modelFileName = modelFileName ?? "\(name.lowercased())_gem"
    }
}

// MARK: - Gemstone Data
let allGemstones: [Gemstone] = [
    Gemstone(name: "Diamond", recipe: [.carbon]),
    Gemstone(name: "Amethyst", recipe: [.oxygen, .silicon]),
    Gemstone(name: "Ruby", recipe: [.aluminum, .oxygen]),
    Gemstone(name: "Sapphire", recipe: [.aluminum, .oxygen]),
    Gemstone(name: "Pearl", recipe: [.calcium, .carbon, .oxygen]),
    Gemstone(name: "Opal", recipe: [.hydrogen, .oxygen, .silicon]),
    Gemstone(name: "Peridot", recipe: [.magnesium, .oxygen, .silicon]),
    Gemstone(name: "Alexandrite", recipe: [.aluminum, .beryllium, .oxygen]),
    Gemstone(name: "Emerald", recipe: [.aluminum, .beryllium, .oxygen, .silicon]),
    Gemstone(name: "Aquamarine", recipe: [.aluminum, .beryllium, .oxygen, .silicon]),
    Gemstone(name: "Garnet", recipe: [.aluminum, .magnesium, .oxygen, .silicon]),
    Gemstone(name: "Spinel", recipe: [.aluminum, .magnesium, .oxygen]),
    Gemstone(name: "Topaz", recipe: [.aluminum, .fluorine, .hydrogen, .oxygen, .silicon]),
    Gemstone(name: "Turquoise", recipe: [.aluminum, .hydrogen, .oxygen, .phosphorus, .copper]),
    Gemstone(name: "Zircon", recipe: [.oxygen, .silicon, .zirconium]),
    Gemstone(name: "Tourmaline", recipe: [.aluminum, .boron, .fluorine, .hydrogen, .lithium, .oxygen, .silicon, .sodium])
]

// MARK: - Gemstone Logic
func createGem(from elems: [Element]) -> Gemstone? {
    let inputElementsSet = Set(elems)
    return allGemstones.first { $0.recipe == inputElementsSet }
}

func formedGemstones(from elements: [Element]) -> [Gemstone] {
    let inputSet = Set(elements)
    return allGemstones.filter { $0.recipe.isSubset(of: inputSet) }
}

func formedGemstones(from elements: [Element]) -> [String] {
    let inputSet = Set(elements)
    return allGemstones
        .filter { $0.recipe.isSubset(of: inputSet) }
        .map { $0.name }
}

struct Model3D: Identifiable {
    let id = UUID()
    let fileName: String
    let displayName: String
    let category: String
    
    init(from gemstone: Gemstone) {
        self.fileName = gemstone.modelFileName
        self.displayName = gemstone.name
        self.category = gemstone.category
    }
    
    init(fileName: String, displayName: String, category: String) {
        self.fileName = fileName
        self.displayName = displayName
        self.category = category
    }
}

let gemstoneModels: [Model3D] = allGemstones.map { Model3D(from: $0) }

var allModels: [Model3D] {
    var models: [Model3D] = []
    
    // Gemstones
    models.append(contentsOf: gemstoneModels)
    
    return models
}
