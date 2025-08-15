//
//  SLGridLayout.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 15/08/25.
//
import SwiftUI

/// A flexible SwiftUI grid container for displaying identifiable items in either
/// a vertical (`LazyVGrid`) or horizontal (`LazyHGrid`) layout.
/// - Note: `Data.Element` must conform to `Identifiable`.
/// - Generic Parameters:
///   - `Data`: A `RandomAccessCollection` of items to render.
///   - `Content`: The SwiftUI `View` built for each item using the `content` closure.
/// - Features:
///   - Configure column/row count via `numberOfLayout`.
///   - Control item width with `itemSizeRatio` relative to `containerSize`.
///   - Switch orientation with `isVertical`.
///   - Handle taps via the optional `action` closure.
@available(iOS 15.0, *)
public struct SLGridLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    /// The source collection of items to be displayed in the grid.
    /// Must be a `RandomAccessCollection` whose elements are `Identifiable`.
    public let items: Data
    
    /// The base container width used to derive individual item width.
    /// Defaults to the device screen width if not provided.
    let containerSize: CGFloat
    
    /// The fraction of `containerSize` used as the item width.
    /// Example: `0.45` means each item is `45%` of the container width.
    let itemSizeRatio: CGFloat
    
    /// The underlying grid specification used by `LazyVGrid`/`LazyHGrid`.
    /// Built from `numberOfLayout` as an array of `.flexible()` grid items.
    let layout: [GridItem]
    
    /// Controls grid orientation.
    /// - `true`: Uses `LazyVGrid` (vertical scrolling).
    /// - `false`: Uses `LazyHGrid` within a horizontal `ScrollView`.
    let isVertical: Bool 
    
    /// A builder closure that produces the view for a given item.
    /// Called for each element in `items` to render cell content.
    public var content: (Data.Element) -> Content
    
    /// Optional tap handler receiving the tapped item.
    /// Called for each element in `items` to handle cell's tap action.
    public var action: ((Data.Element) -> Void)?
    
    /// Creates an `SLGridLayout`.
    /// - Parameters:
    ///   - items: The collection of items to render.
    ///   - numberOfLayout: The number of columns (vertical) or rows (horizontal). Default is `2`.
    ///   - itemSizeRatio: Multiplier applied to `containerSize` to compute item width. Default is `0.65`.
    ///   - isVertical: Whether to layout as a vertical grid (`LazyVGrid`) or as a horizontal grid (`LazyHGrid`). Default is `true` (vertical).
    ///   - containerSize: Optional base size used to compute item width. Defaults to `UIScreen.main.bounds.width`.
    ///   - content: A closure that builds the view for each item.
    ///   - action: Optional tap handler receiving the tapped item.
    public init(items: Data,
         numberOfLayout: Int = 2,
         itemSizeRatio: CGFloat = 0.65,
         isVertical: Bool = true,
         containerSize: CGFloat? = nil,
         content: @escaping (Data.Element) -> Content, 
         action: ((Data.Element) -> Void)? = nil) {
        self.items = items
        self.itemSizeRatio = itemSizeRatio
        self.layout = Array(repeating: GridItem(.flexible()), count: numberOfLayout)
        self.isVertical = isVertical
        self.content = content
        self.action = action
        self.containerSize = containerSize ?? UIScreen.main.bounds.width
    }
    
    /// Renders the grid using either `LazyVGrid` (vertical) or `LazyHGrid` (horizontal),
    /// computing each item's width as `containerSize * itemSizeRatio`.
    public var body: some View {
        VStack {
            let cardWidth: CGFloat = containerSize * itemSizeRatio
            
            if isVertical {
                LazyVGrid(columns: layout, spacing: 12) { 
                    GridLayout(cardWidth: cardWidth)                
                }
            } else {
                ScrollView(.horizontal ,showsIndicators: false) {
                    LazyHGrid(rows: layout, spacing: 12) { 
                        GridLayout(cardWidth: cardWidth)
                    }
                }
            }
            
        }
    }
    
    /// Builds the internal grid content using `ForEach` with stable `id`s.
    /// - Parameter cardWidth: The computed width applied to each item.
    @ViewBuilder 
    private func GridLayout(cardWidth: CGFloat) -> some View {
        ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
            ItemView(item, for: index, with: cardWidth)
        }
    }
    
    /// Wraps a single item view with sizing and tap handling.
    /// - Parameters:
    ///   - item: The item to display.
    ///   - index: The position of the item in the collection.
    ///   - cardWidth: The width applied to the item's view.
    @ViewBuilder
    private func ItemView(_ item: Data.Element, for index: Int, with cardWidth: CGFloat) -> some View {
        content(item)
            .frame(width: cardWidth)            
            .onTapGesture {
                action?(item)
            }
    }
}
