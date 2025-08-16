//
//  SLStackCarouselLayout.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 16/08/25.
//

import SwiftUI

/// A stacked, swipeable carousel layout for SwiftUI.
/// Displays items as layered cards with scaling, offset, and z-index to simulate depth.
/// Supports tap-to-select and drag-to-swipe interactions.
///
/// - Note: `Data.Element` must conform to `Identifiable`.
/// - Generic Parameters:
///   - `Data`: A `RandomAccessCollection` of identifiable items.
///   - `Content`: The SwiftUI view generated for each item via `content`.
@available(iOS 15.0, *)
public struct SLStackCarouselLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    /// The data source for the carousel, rendered in stacking order.
    let items: Data
    /// Visual and interaction configuration for widths, spacing, scaling, and visibility.
    let config: SLStackCarouselModel
    /// The index of the currently centered (selected) card.
    /// Updates as the user swipes or taps other cards.
    @Binding var currentIndex: Int
    /// Builder that produces the view for each item.
    let content: (Data.Element) -> Content
    /// Callback executed when the currently selected card is tapped.
    /// If a non-selected card is tapped, the carousel first animates towards it instead of firing this action.
    let action: ((Data.Element) -> Void)?
    
    /// Creates an `SLStackCarouselLayout`.
    /// - Parameters:
    ///   - items: The collection of items to render.
    ///   - config: The visual configuration based on `SLStackCarouselModel` protocol for Layout's UI
    ///   - currentIndex: index of the item which is in focus then maintains bind to track the same
    ///   - content: A closure that builds the view for each item.
    ///   - action: Optional tap handler receiving the tapped item.
    public init(items: Data, 
         config: SLStackCarouselModel, 
         currentIndex: Binding<Int>, 
         content: @escaping (Data.Element) -> Content,
         action: ((Data.Element) -> Void)? = nil) {
        self.items = items
        self.config = config
        self._currentIndex = currentIndex
        self.content = content
        self.action = action
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let cardWidth: CGFloat = proxy.size.width * config.cardWidthRatio

            VStack {
                ZStack {
                    ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
                        ItemView(item, for: index, with: cardWidth)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onEnded { value in
                            scrollEffect(value)
                        }
                )
            }
        }
    }
    
    /// Renders a single card with scale, x-offset, z-index, and opacity based on its distance from `currentIndex`.
    /// - Parameters:
    ///   - item: The model for the card.
    ///   - index: The card's index in `items`.
    ///   - cardWidth: The computed width for the card.
    @ViewBuilder
    private func ItemView(_ item: Data.Element, for index: Int, with cardWidth: CGFloat) -> some View {
        let offsetFromCurrent = index - currentIndex
        
        let scale = offsetFromCurrent == 0 ? 1 : (1 - Double(abs(offsetFromCurrent)) * config.cardSizeDifferenceRatio)
        let xOffset = CGFloat(offsetFromCurrent) * config.cardOffsetDifference
        let zIndex = Double(items.count - abs(offsetFromCurrent))
        
        content(item)
            .frame(width: cardWidth)
            .scaleEffect(scale)
            .offset(x: xOffset)
            .zIndex(zIndex)
            .opacity(abs(offsetFromCurrent) <= Int(config.visibleCardIndexDifference) ? 1 : 0)
            .transition(.opacity)
            .animation(.linear, value: currentIndex)
            .onTapGesture {
                handleTapAction(for: item, at: index)
            }
            .overlay { 
                if (currentIndex == index) && config.showSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.black, lineWidth: 2)
                }
            }
    }
    
    /// Paginates the carousel based on drag direction and a small threshold.
    /// - Parameter value: The completed drag gesture value.
    private func scrollEffect(_ value: DragGesture.Value) {
        let threshold: CGFloat = 25
        if value.translation.width < -threshold && currentIndex < items.count - 1 {
            currentIndex += 1
        } else if value.translation.width > threshold && currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    /// Handles taps: if tapping a non-selected card, move selection by one toward it; if tapping the selected card, fire `action`.
    /// - Parameters:
    ///   - item: The tapped item.
    ///   - index: The index of the tapped item.
    private func handleTapAction(for item: Data.Element, at index: Int) {
        if index != currentIndex {
            currentIndex += index > currentIndex ? 1 : -1
        } else {
            action?(item)
        }
    }
}
