//
//  GemCreator.swift
//  Gemify
//
//  Created by Francisco Mestizo on 30/09/25.
//

import Foundation
import SwiftUI

enum Element: String, CaseIterable, Codable {
    case hydrogen, lithium, beryllium, boron, carbon, oxygen
    case fluorine, sodium, magnesium, aluminum, silicon
    case phosphorus, calcium, copper, zirconium
    
    var symbol: String {
        switch self {
        case .hydrogen: return "H"
        case .lithium: return "Li"
        case .beryllium: return "Be"
        case .boron: return "B"
        case .carbon: return "C"
        case .oxygen: return "O"
        case .fluorine: return "F"
        case .sodium: return "Na"
        case .magnesium: return "Mg"
        case .aluminum: return "Al"
        case .silicon: return "Si"
        case .phosphorus: return "P"
        case .calcium: return "Ca"
        case .copper: return "Cu"
        case .zirconium: return "Zr"
        }
    }
    
    var name: String {
        switch self {
        case .hydrogen: return "Hydrogen"
        case .lithium: return "Lithium"
        case .beryllium: return "Beryllium"
        case .boron: return "Boron"
        case .carbon: return "Carbon"
        case .oxygen: return "Oxygen"
        case .fluorine: return "Fluorine"
        case .sodium: return "Sodium"
        case .magnesium: return "Magnesium"
        case .aluminum: return "Aluminum"
        case .silicon: return "Silicon"
        case .phosphorus: return "Phosphorus"
        case .calcium: return "Calcium"
        case .copper: return "Copper"
        case .zirconium: return "Zirconium"
        }
    }
    
    var atomicNumber: Int {
        switch self {
        case .hydrogen: return 1
        case .lithium: return 3
        case .beryllium: return 4
        case .boron: return 5
        case .carbon: return 6
        case .oxygen: return 8
        case .fluorine: return 9
        case .sodium: return 11
        case .magnesium: return 12
        case .aluminum: return 13
        case .silicon: return 14
        case .phosphorus: return 15
        case .calcium: return 20
        case .copper: return 29
        case .zirconium: return 40
        }
    }
    
    init?(symbol: String) {
        guard let match = Element.allCases.first(where: {
            $0.symbol.lowercased() == symbol.lowercased()
        }) else {
            return nil
        }
        self = match
    }
}

// MARK: - UI Wrapper
struct ChemicalElement: Identifiable {
    let id = UUID()
    let element: Element
    
    var symbol: String { element.symbol }
    var name: String { element.name }
    var atomicNumber: Int { element.atomicNumber }
    
    func toDraggable() -> DraggableElement {
        DraggableElement(
            symbol: element.symbol,
            name: element.name,
            atomicNumber: element.atomicNumber,
            elementType: element.rawValue
        )
    }
}

// MARK: - Data
let chemicalElements: [ChemicalElement] = Element.allCases.map {
    ChemicalElement(element: $0)
}

func getElementColor(_ element: ChemicalElement) -> UIColor {
    switch element.symbol {
    case "H": return .systemRed
    case "Li", "Na", "Ca": return .systemPurple
    case "Be", "Mg", "Al": return .systemBlue
    case "B", "C", "Si": return .systemBrown
    case "O", "F": return .systemGreen
    case "P": return .systemOrange
    case "Cu", "Zr": return .systemCyan
    default: return .systemGray
    }
}
