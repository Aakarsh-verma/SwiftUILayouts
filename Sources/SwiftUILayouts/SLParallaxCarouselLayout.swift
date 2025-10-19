//
//  SLParallaxCarouselLayout.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 18/08/25.
//

import SwiftUI

// MARK: - SLParallaxCarouselLayout
/// A horizontally-scrolling carousel that uses *parallax* and *scale* effects
/// to create depth.
///
/// Generic parameters:
/// - `Data` – a `RandomAccessCollection` whose `Element` is `Identifiable` & `SLImageModel`  
/// - `Content` – front-most view inside each card (often an image)  
/// - `OverlayContent` – optional overlay drawn above the card
public struct SLParallaxCarouselLayout<Data: RandomAccessCollection, Content: View, OverlayContent: View>: View where Data.Element: Identifiable & SLImageModel {
    /// **Source collection** whose elements become individual cards in the carousel. Order is preserved.
    let items: Data
    /// **Look & feel configuration** (spacing, parallax scale, corner radius, frame height…)
    let config: SLParallaxCarouselProtocol
    /// Builder that produces the **main view** for a card from its data model.
    let content: (Data.Element) -> Content
    /// Builder that produces an **overlay** placed on top of each card.
    /// Useful for badges, gradients, or buttons. Return `EmptyView()` if not
    /// needed.
    let overlayContent: (Data.Element) -> OverlayContent
    
    // MARK: Initialiser
    /**
     Creates a parallax carousel.
     
     - Parameters:
     - items: **Ordered collection** whose elements become cards in the
     carousel. Each element must be both `Identifiable` and `SLImageModel`
     so the view can key the `ForEach` and fetch an image for parallax.
     - config: **Look-and-feel settings** such as spacing, corner radius,
     parallax factor, and carousel height.  
     Pass any value that conforms to `SLParallaxCarouselConfigProtocol`.
     Defaults to `SLParallaxCarouselConfig()` (the standard preset).
     - content: **Foreground builder**. Closure that turns one data element
     into the main view shown on the card. For example:
     ```
     { item in
     Image(item.imageName)
     .resizable()
     .scaledToFill()
     }
     ```
     - overlayContent: **Overlay builder** drawn **above** the card. Used for
     text labels, gradients, or buttons. If you don’t need an overlay,
     return `EmptyView()`:
     ```
     { _ in EmptyView() }
     ```
     */
    public init(items: Data,
                config: SLParallaxCarouselProtocol,
                content: @escaping (Data.Element) -> Content,
                overlayContent: @escaping (Data.Element) -> OverlayContent) {
        self.items = items
        self.config = config
        self.content = content
        self.overlayContent = overlayContent
    }
    
    public var body: some View {
        carouselView()
            .frame(height: config.frameHeight)
            .padding(.top, 10)
    }
    
    @ViewBuilder 
    private func carouselView() -> some View {
        GeometryReader { geometry in
            let size = geometry.size
            let smallerScale: CGFloat = config.nonCenterItemScale
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: config.itemSpacing) {
                    ForEach(Array(items.enumerated()), id: \.1.id) { _, trip in
                        GeometryReader { proxy in
                            let cardSize = proxy.size
                            let minX = parallaxOffset(proxy: proxy, cardSize: cardSize)
                            content(trip)
                                .offset(x: -minX)
                                .frame(width: cardSize.width, height: cardSize.height)
                                .overlay {
                                    overlayContent(trip)
                                }
                                .clipShape(.rect(cornerRadius: config.cornerRadius))
                        }
                        .frame(width: size.width, height: size.height)
                        .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                            view.scaleEffect(
                                phase.isIdentity ? 1 : smallerScale
                            )
                        }
                    }
                }
                .scrollTargetLayout()
                .frame(height: size.height, alignment: .top)
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    /// Calculates how far the inner content must shift to create parallax.
    /// - Returns: A positive value that is subtracted from the content’s `x`
    ///   position (hence the minus sign in `offset(x: -xOffset)`).
    private func parallaxOffset(proxy: GeometryProxy, cardSize: CGSize) -> CGFloat {
        let raw = (proxy.frame(in: .scrollView).minX - 30) * config.parallaxScale
        return min(raw, cardSize.width * config.parallaxScale)
    }
}
