//
//  SLStackCarouselModel.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 16/08/25.
//

import SwiftUI

/// A configuration protocol for `SLStackCarouselLayout`.
/// Defines how cards are sized, spaced, layered, and whether selection is highlighted.
/// Conform to this protocol to tune the visual behavior of the stacked carousel.
public protocol StackCarouselConfigModel {
    /// Portion of the container width used for each card's width.
    /// Example: `0.75` means each card is 75% of the available width.
    var cardWidthRatio: CGFloat { get }

    /// How much each successive card scales down as it moves away from center.
    /// Larger values create stronger size falloff.
    var cardSizeDifferenceRatio: CGFloat { get }

    /// Horizontal offset delta between adjacent cards.
    /// Positive values push cards to the right as the index increases.
    var cardOffsetDifference: CGFloat { get }

    /// Maximum absolute index distance from the current card that remains visible.
    /// Cards with |offset| greater than this become fully transparent.
    var visibleCardIndexDifference: CGFloat { get }

    /// Whether to draw a highlight (e.g., stroke) around the currently selected card.
    var showSelected: Bool { get }
}

/// Default helper methods for `StackCarouselConfigModel`.
/// Provides computed presentation properties for a card based on its offset from the current index.
extension StackCarouselConfigModel {
    /// Computes visual properties for a card in the stack given its distance from the selected card.
    /// - Parameters:
    ///   - offsetFromCurrent: Relative index distance from the currently selected card (0 for selected, negative for left, positive for right).
    ///   - totalItems: Total number of items in the carousel, used to compute layering (`zIndex`).
    /// - Returns: A tuple of:
    ///   - scale: The scale applied to the card (1 for the selected card, decreasing by `cardSizeDifferenceRatio` per step).
    ///   - xOffset: Horizontal offset computed as `offset * cardOffsetDifference`.
    ///   - zIndex: The stacking order (higher values appear above lower ones).
    ///   - opacity: `1` if within `visibleCardIndexDifference`, else `0`.
    func getItemsProps(_ offsetFromCurrent: Int, totalItems: Int) -> (scale: CGFloat, xOffset: CGFloat, zIndex: Double, opacity: Double) {
        let scale = offsetFromCurrent == 0 ? 1 : (1 - Double(abs(offsetFromCurrent)) * cardSizeDifferenceRatio)
        let xOffset = CGFloat(offsetFromCurrent) * cardOffsetDifference
        let zIndex = Double(totalItems - abs(offsetFromCurrent))
        let opacity = abs(offsetFromCurrent) <= Int(visibleCardIndexDifference) ? 1.0 : 0.0
        return (scale, xOffset, zIndex, opacity)
    }
}
