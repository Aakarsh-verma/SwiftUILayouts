//
//  ParallaxCarouselView.swift
//  SwiftUICarousels
//
//  Created by Aakarsh Verma on 18/05/25.
//

import SwiftUI
import SwiftUILayouts

struct ParallaxConfig: SLParallaxCarouselProtocol {
    var itemSpacing: CGFloat = 5
    var parallaxScale: CGFloat = 1.4
    var cornerRadius: CGFloat = 12
    var nonCenterItemScale: CGFloat = 0.95
    var frameHeight: CGFloat = 500
}

#Preview {
    SLParallaxCarouselLayout(items: sampleImages, config: ParallaxConfig()) { item in
        SLImageView(CustomImageModel(image: item.image))
            .aspectRatio(contentMode: .fill)
            .shadow(color: .black.opacity(0.25), radius: 20, x: 100, y: 100)
    } overlayContent: { item in
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [
                .clear,
                .clear,
                .clear,
                .clear,
                .clear,
                .black.opacity(0.1),
                .black.opacity(0.5),
                .black
            ], startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.image)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text(item.image)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
        }
    }
}
