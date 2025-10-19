//
//  SLCarouselModels.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 16/08/25.
//

import SwiftUI

// MARK: - SLStackCarouselProtocol

/// A configuration protocol for `SLStackCarouselLayout`.
/// Defines how cards are sized, spaced, layered, and whether selection is highlighted.
/// Conform to this protocol to tune the visual behavior of the stacked carousel.
public protocol SLStackCarouselProtocol {
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
extension SLStackCarouselProtocol {
    /// Computes visual properties for a card in the stack given its distance from the selected card.
    /// - Parameters:
    ///   - offsetFromCurrent: Relative index distance from the currently selected card (0 for selected, negative for left, positive for right).
    ///   - totalItems: Total number of items in the carousel, used to compute layering (`zIndex`).
    /// - Returns: A model of `SLStackCarouselProps` which contains:
    ///   - scale: The scale applied to the card (1 for the selected card, decreasing by `cardSizeDifferenceRatio` per step).
    ///   - xOffset: Horizontal offset computed as `offset * cardOffsetDifference`.
    ///   - zIndex: The stacking order (higher values appear above lower ones).
    ///   - opacity: `1` if within `visibleCardIndexDifference`, else `0`.
    func getItemsProps(_ offsetFromCurrent: Int, totalItems: Int) -> SLStackCarouselProps {
        let scale = offsetFromCurrent == 0 ? 1 : (1 - Double(abs(offsetFromCurrent)) * cardSizeDifferenceRatio)
        let xOffset = CGFloat(offsetFromCurrent) * cardOffsetDifference
        let zIndex = Double(totalItems - abs(offsetFromCurrent))
        let opacity = abs(offsetFromCurrent) <= Int(visibleCardIndexDifference) ? 1.0 : 0.0
        return SLStackCarouselProps(scale, xOffset, zIndex, opacity)
    }
}

/// helper model for `StackCarouselConfigModel`.
/// Contains computed presentation properties for a card
internal struct SLStackCarouselProps {
    /// The scale applied to the card
    let scale: CGFloat
    /// Horizontal offset
    let xOffset: CGFloat
    /// The stacking order
    let zIndex: Double
    /// Is there even a need to explains? ; )
    let opacity: CGFloat
    /// Creates an `SLStackCarouselProps`.
    init(_ scale: CGFloat, 
         _ xOffset: CGFloat, 
         _ zIndex: Double, 
         _ opacity: CGFloat) {
        self.scale = scale
        self.xOffset = xOffset
        self.zIndex = zIndex
        self.opacity = opacity
    }
}

// MARK: - SLCoverCarouselProtocol

/// A configuration protocol for `SLCoverCarouselLayout`.
/// Defines how cards are sized, spaced, layered, and whether selection is highlighted.
/// Conform to this protocol to tune the visual behavior of the cover carousel.
public protocol SLCoverCarouselProtocol {
    /// Enable translucent behaviour where carousel item have lesser opacity when further away from center item    
    var hasOpacity: Bool { get }
    
    /// opacity multiplier based on how much further away certain items are from center item   
    var opacityValue: CGFloat { get }
    
    /// Enable the scaling difference where carousel item have lesser size when further away from center item
    var hasScale: Bool { get }
    
    /// scaling multiplier based on how much further away certain items are from center item   
    var scaleValue: CGFloat { get }
    
    /// normal width of carousel item
    var cardWidth: CGFloat { get }
    
    /// spacing between carousel item
    var spacing: CGFloat { get }
    
    /// corner radius of carousel item
    var cornerRadius: CGFloat { get }
    
    /// minimum width of carousel item
    var minimumCardWidth: CGFloat { get }
}

// MARK: - SLAmbientCarouselProtocol

/// Describes all visual and layout parameters used by `AmbientCarouselView`.
///
/// Conforming types supply values (or computed values) for each property; the
/// protocol ships with default values via an extension so you only override
/// the ones you care about.
///
/// Typical usage:
///
/// ```
/// struct DarkModeCarouselConfig: SLAmbientCarouselProtocol {
///     let backgroundBlurDarkness: CGFloat = 0.6      // darker backdrop
///     let itemSpacing:            CGFloat = 16        // wider spacing
/// }
///
/// let view = AmbientCarouselView(
///     config: DarkModeCarouselConfig(),
///     items:  myImages
/// ) { image in
///     SLImageView(CustomImageModel(image: image.image))
/// }
/// ```
@available(iOS 18.0, *)
public protocol SLAmbientCarouselProtocol {
    /// Amount of the backdrop (in points) kept *above* the visible carousel
    /// for a smooth fade-out effect.
    var visibleTopBlur: CGFloat { get }
    
    /// Amount of the backdrop (in points) kept *below* the visible carousel
    /// for a smooth fade-out effect.
    var visibleBottomBlur: CGFloat { get }
    
    /// The radius, in points, of the Gaussian blur applied to the backdrop.
    var backgroundBlurRadius: CGFloat { get }
    
    /// The alpha-component (0 … 1) of a black overlay placed on top of the
    /// blurred backdrop to darken it.
    var backgroundBlurDarkness: CGFloat { get }
    
    /// Fixed height of the carousel itself.
    var frameHeight: CGFloat { get }
    
    /// Horizontal spacing between consecutive carousel items.
    var itemSpacing: CGFloat { get }
}

// MARK: - SLParallaxCarouselProtocol
/// Describes all tunable parameters used by `SLParallaxCarouselLayout`.
///
/// Conform with either a *value-type* configuration:
///
/// ```
/// struct DarkThemeParallaxConfig: SLParallaxCarouselProtocol {
///     let backgroundBlurDarkness: CGFloat = 0.6
///     let itemSpacing:            CGFloat = 12
/// }
/// ```
///
public protocol SLParallaxCarouselProtocol {
    /// Horizontal gap between cards.
    var itemSpacing: CGFloat { get }

    /// Extra scale applied to the *image inside* each card to give room for the
    /// parallax reveal.
    var parallaxScale: CGFloat { get }

    /// Corner radius of the clipped card.
    var cornerRadius: CGFloat { get }

    /// Scale applied to non-centred cards during interactive scrolling.
    var nonCenterItemScale: CGFloat { get }

    /// Fixed height of the carousel view.
    var frameHeight: CGFloat { get }
}
