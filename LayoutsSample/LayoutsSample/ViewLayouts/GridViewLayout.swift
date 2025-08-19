//
//  GridViewLayout.swift
//  LayoutsSample
//
//  Created by Aakarsh Verma on 12/08/25.
//

import SwiftUI
import SwiftUILayouts

#Preview {
    ScrollView { 
        SLGridLayout(items: sampleImages,
                     numberOfLayout: 2,
                     itemSizeRatio: 0.45,
                     isVertical: true,
                     containerSize: nil) { item in
            Image(item.image)
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 20))
        }
    }
}
