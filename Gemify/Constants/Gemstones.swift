//
//  Gemstones.swift
//  Gemify
//
//  Created by Francisco Mestizo on 30/09/25.
//

import SwiftUI

let allGemstones: [Gemstone] = [Gemstone(name: "Diamond", recipe: [.carbon]),
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
                                Gemstone(name: "Tourmaline", recipe: [.aluminum, .boron, .fluorine, .hydrogen, .lithium, .oxygen, .silicon, .sodium])]


struct Elements: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let atomicNumber: Int     
}

let elements: [Elements] = [
    Elements(name: "Carbon", symbol: "C", atomicNumber: 6),
    Elements(name: "Oxygen", symbol: "O", atomicNumber: 8),
    Elements(name: "Silicon", symbol: "Si", atomicNumber: 14),
    Elements(name: "Aluminum", symbol: "Al", atomicNumber: 13),
    Elements(name: "Calcium", symbol: "Ca", atomicNumber: 20),
    Elements(name: "Hydrogen", symbol: "H", atomicNumber: 1),
    Elements(name: "Magnesium", symbol: "Mg", atomicNumber: 12),
    Elements(name: "Beryllium", symbol: "Be", atomicNumber: 4),
    Elements(name: "Fluorine", symbol: "F", atomicNumber: 9),
    Elements(name: "Phosphorus", symbol: "P", atomicNumber: 15),
    Elements(name: "Copper", symbol: "Cu", atomicNumber: 29),
    Elements(name: "Zirconium", symbol: "Zr", atomicNumber: 40),
    Elements(name: "Boron", symbol: "B", atomicNumber: 5),
    Elements(name: "Lithium", symbol: "Li", atomicNumber: 3),
    Elements(name: "Sodium", symbol: "Na", atomicNumber: 11)
]

