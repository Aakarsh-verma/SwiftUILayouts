//
//  StackCarouselView.swift
//  SwiftUICarousels
//
//  Created by Aakarsh Verma on 24/05/25.
//

import SwiftUI
import SwiftUILayouts

enum StackCarouselType {
    case center
}

public struct StackCarouselConfigModel: SLStackCarouselProtocol {
    public var cardWidthRatio: CGFloat
    public var cardSizeDifferenceRatio: CGFloat
    public var cardOffsetDifference: CGFloat
    public var visibleCardIndexDifference: CGFloat
    public var showSelected: Bool
//    var constantDistance: CGFloat?
//    var isInfinite: Bool
    
    public init(cardWidthRatio: CGFloat = 0.65,
                cardSizeDifferenceRatio: CGFloat = 0.15,
                cardOffsetDifference: CGFloat = 50.0,
                visibleCardIndexDifference: CGFloat = 1.0,
                constantDistance: CGFloat? = nil,
                showSelected: Bool = false,
                isInfinite: Bool = false) {
        self.cardWidthRatio = cardWidthRatio
        self.cardSizeDifferenceRatio = cardSizeDifferenceRatio
        self.cardOffsetDifference = cardOffsetDifference
        self.visibleCardIndexDifference = visibleCardIndexDifference
//        self.constantDistance = constantDistance
        self.showSelected = showSelected
//        self.isInfinite = isInfinite
    }
}

#Preview {
    @Previewable @State var currentIndex = 1
    SLStackCarouselLayout(items: sampleImages, config: StackCarouselConfigModel(), currentIndex: $currentIndex) { imageModel in
        SLImageView(CustomImageModel(image: imageModel.image))
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 20))
    } action: {_ in}
}
