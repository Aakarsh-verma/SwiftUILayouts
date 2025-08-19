//
//  CustomCarouselView.swift
//  SwiftUICarousels
//
//  Created by Aakarsh Verma on 04/05/25.
//

import SwiftUI
import SwiftUILayouts

struct Config: SLCoverCarouselProtocol {    
    var hasOpacity: Bool = false
    var opacityValue: CGFloat = 0.4
    var hasScale: Bool = false
    var scaleValue: CGFloat = 0.2
    var cardWidth: CGFloat = 150
    var spacing: CGFloat = 10
    var cornerRadius: CGFloat = 15
    var minimumCardWidth: CGFloat = 40
}

#Preview {
    @Previewable @State var activeID: UUID?
    SLCoverCarouselLayout(config: Config(hasOpacity: true, hasScale: true), data: sampleImages, selection: $activeID, content: { item in
        SLImageView(CustomImageModel(image: item.image))
            .aspectRatio(contentMode: .fill)

    })
    .frame(height: 240)
}
