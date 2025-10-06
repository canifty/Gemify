//
//  Gemstones.swift
//  Gemify
//
//  Created by Francisco Mestizo on 30/09/25.
//

import SwiftUI

let allGemstones: [Gemstone] = [Gemstone(name: "Diamond", recipe: [.carbon]),

                                Gemstone(name: "Amethyst", recipe: [.oxigen, .silicon]),
                                Gemstone(name: "Ruby", recipe: [.aluminum, .oxigen]),
                                Gemstone(name: "Sapphire", recipe: [.aluminum, .oxigen]),
                                Gemstone(name: "Pearl", recipe: [.calcium, .carbon, .oxigen]),
                                Gemstone(name: "Opal", recipe: [.hydrogen, .oxigen, .silicon]),
                                Gemstone(name: "Peridot", recipe: [.magnesium, .oxigen, .silicon]),
                                Gemstone(name: "Alexandrite", recipe: [.aluminum, .beryllium, .oxigen]),
                                Gemstone(name: "Emerald", recipe: [.aluminum, .beryllium, .oxigen, .silicon]),
                                Gemstone(name: "Aquamarine", recipe: [.aluminum, .beryllium, .oxigen, .silicon]),
                                Gemstone(name: "Garnet", recipe: [.aluminum, .magnesium, .oxigen, .silicon]),
                                Gemstone(name: "Spinel", recipe: [.aluminum, .magnesium, .oxigen]),
                                Gemstone(name: "Topaz", recipe: [.aluminum, .fluorine, .hydrogen, .oxigen, .silicon]),
                                Gemstone(name: "Turquoise", recipe: [.aluminum, .hydrogen, .oxigen, .phosphorus, .copper]),
                                Gemstone(name: "Zircon", recipe: [.oxigen, .silicon, .zirconium]),
                                Gemstone(name: "Tourmaline", recipe: [.aluminum, .boron, .fluorine, .hydrogen, .lithium, .oxigen, .silicon, .sodium])]


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


