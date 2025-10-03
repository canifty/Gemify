//
//  GemCreator.swift
//  Gemify
//
//  Created by Francisco Mestizo on 30/09/25.
//

import Foundation

enum Element {
    case oxigen, aluminum, silicon, hydrogen, magnesium, carbon, beryllium, calcium, fluorine, phosphorus, zirconium, boron, lithium, sodium, copper
}

struct Gemstone {
    let name: String
    let recipe: Set<Element>
}

func createGem(from elems: [Element]) -> Gemstone? {
    let inputElementsSet = Set(elems)
    return allGemstones.first { $0.recipe == inputElementsSet }
}

func formedGemstones(from elements: [Element]) -> [String] {
    let inputSet = Set(elements)
    return allGemstones
        .filter { $0.recipe.isSubset(of: inputSet) }
        .map { $0.name }
}


