//
//  SegmentedControlView.swift
//  Gemify
//
//  Created by Gizem Coskun on 03/10/25.
//

import SwiftUI

struct SegmentedControlView: View {
    
    @Binding private var selection: String
    
    init(selection: Binding<String>) {
        self._selection = selection
    }
    
    var body: some View {
        Picker("Options", selection: $selection) {
            Text("Elements").tag("elements")
            Text("Gems").tag("gems")
        }
        .pickerStyle(.segmented)
        .frame(width: 212)
        .glassBackgroundEffect()
    }
}

#Preview{
    SegmentedControlView(selection: .constant("elements"))
}
