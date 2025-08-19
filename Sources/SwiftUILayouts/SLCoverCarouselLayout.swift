//
//  SLCoverCarouselLayout.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 17/08/25.
//

import SwiftUI

/// A horizontally scrolling cover-style carousel with optional scale/opacity effects, within a given frame height
///
/// - Parameters:
///   - Content: The SwiftUI view built for each data element.
///   - Data: A `RandomAccessCollection` whose `Element` is `Identifiable`.
public struct SLCoverCarouselLayout<Content: View, Data: RandomAccessCollection>: View where Data.Element: Identifiable {
    /// Model controlling card size, spacing and visual effects.
    private let config: SLCoverCarouselProtocol
    /// Items to display.
    private let data: Data
    /// Currently selected item ID (two-way binding to the caller).
    @Binding private var selection: Data.Element.ID?
    /// Builder that turns each data element into a view.
    @ViewBuilder private var content: (Data.Element) -> Content
    
    public init(config: SLCoverCarouselProtocol, 
                data: Data, 
                selection: Binding<Data.Element.ID?>, 
                content: @escaping (Data.Element) -> Content) {
        self.config = config
        self.data = data
        self._selection = selection
        self.content = content
    }
    
    public var body: some View {
        carouselView()
    }
    
    @ViewBuilder
    private func carouselView() -> some View {
        GeometryReader { rootProxy in
            let rootSize = rootProxy.size
            ScrollView(.horizontal) {
                HStack(spacing: config.spacing) {
                    ForEach(data) { item in
                        SLCoverCarouselCard(
                            item: item,
                            config: config,
                            content: { content(item) }
                        )
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.horizontal, max(rootSize.width - config.cardWidth, 0) / 2)
            .scrollPosition(id: $selection)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - Private Sub-views & Helpers

/// Single card inside the carousel.
private struct SLCoverCarouselCard<Item: Identifiable, Content: View>: View {
    
    let item: Item
    let config: SLCoverCarouselProtocol
    @ViewBuilder var content: () -> Content
    
    private var diffWidth: CGFloat { config.cardWidth - config.minimumCardWidth }
    
    var body: some View {
        GeometryReader { proxy in
            let metrics = SLCoverCarouselItemMetrics(
                proxy: proxy,
                cardWidth: config.cardWidth,
                spacing: config.spacing,
                diffWidth: diffWidth,
                config: config
            )
            
            content()
                .frame(width: proxy.size.width, height: proxy.size.height)          // original size
                .frame(width: metrics.resizedWidth)      // dynamic resize
                .opacity(config.hasOpacity ? metrics.opacity : 1)
                .scaleEffect(config.hasScale ? metrics.scale : 1)
                .mask {
                    RoundedRectangle(cornerRadius: config.cornerRadius)
                        .frame(height: metrics.maskHeight)
                }
                .offset(x: metrics.totalOffset)
        }
        .frame(width: config.cardWidth)
    }
}

/// Pure-math helper that computes all geometry values for one item.
private struct SLCoverCarouselItemMetrics {
    
    // Inputs
    let minX: CGFloat
    let size: CGSize
    let diffWidth: CGFloat
    let config: SLCoverCarouselProtocol
    
    // Derived values
    let progress: CGFloat
    let resizedWidth: CGFloat
    let scale: CGFloat
    let opacity: CGFloat
    let totalOffset: CGFloat
    let maskHeight: CGFloat
    
    init(proxy: GeometryProxy,
         cardWidth: CGFloat,
         spacing: CGFloat,
         diffWidth: CGFloat,
         config: SLCoverCarouselProtocol) {
        
        self.minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        self.size = proxy.size
        self.diffWidth = diffWidth
        self.config = config
        
        // Scroll progress (−∞ … 1)
        progress = minX / (cardWidth + spacing)
        
        // Width adjustment
        let reducingWidth = diffWidth * progress
        let cappedWidth   = min(diffWidth, reducingWidth)
        resizedWidth = size.width - (minX > 0 ? cappedWidth
                                     : min(-cappedWidth, diffWidth))
        
        // Visual effects
        let absProg = abs(progress)
        scale   = 1 - config.scaleValue   * absProg
        opacity = 1 - config.opacityValue * absProg
        
        // Mask height (prevents bottom clipping on scale)
        maskHeight = config.hasScale ? (1 - config.scaleValue * absProg) * size.height
        : size.height
        
        // Combine the three x-offsets from original code
        totalOffset = -reducingWidth
        + min(progress, 1) * diffWidth
        + max(-progress, 0) * diffWidth
    }
}
