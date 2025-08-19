//
//  AmbientCarouselPreview.swift
//  SwiftUICarousels
//
//  Created by Aakarsh Verma on 17/05/25.
//

import SwiftUI
import SwiftUILayouts

struct AmbientCarouselConfig: SLAmbientCarouselProtocol {
    var frameHeight: CGFloat = 500
    var visibleTopBlur: CGFloat = 100
    var visibleBottomBlur: CGFloat = 100
    var backgroundBlurRadius: CGFloat = 20
    var backgroundBlurDarkness: CGFloat = 0.35
    var frameHeigt: CGFloat = 500
    var itemSpacing: CGFloat = 10
}

#Preview {
    SLAmbientCarouselLayout(config: AmbientCarouselConfig(), items: sampleImages) { item in
        SLImageView(CustomImageModel(image: item.image))
            .aspectRatio(contentMode: .fill)
            .containerRelativeFrame(.horizontal)
            .frame(height: 500)
            .clipShape(.rect(cornerRadius: 12))

    } backdropContent: { item in
        SLImageView(CustomImageModel(image: item.image))
            .aspectRatio(contentMode: .fill)

    }
}
