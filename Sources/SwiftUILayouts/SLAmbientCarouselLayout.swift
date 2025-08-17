//
//  SLAmbientCarouselLayout.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 17/08/25.
//

import SwiftUI


// MARK: - AmbientCarouselView

/// A horizontally-scrolling **cover-flow style** carousel that renders a crisp
/// foreground cell for every item **and** a blurred, darkened backdrop derived
/// from the same data.
///
/// The view is generic over:
/// • `Data`  – any `RandomAccessCollection` whose `Element` conforms to both
///   `Identifiable` *and* `SLImageModel`.
/// • `Content` – the SwiftUI view used as the **foreground** card for each
///   element.
/// • `BackdropContent` – the SwiftUI view used in the **blurred backdrop**
///   (often just the same image without chrome).
///
/// Usage:
///
/// ```
/// struct Demo: View {
///     var body: some View {
///         AmbientCarouselView(
///             config: MyCarouselConfig(),
///             items:  sampleImages,
///             content: { item in
///                 SLImageView(CustomImageModel(image: item.image))
///                     .aspectRatio(contentMode: .fill)
///                     .clipShape(.rect(cornerRadius: 12))
///             },
///             backdropContent: { item in
///                 SLImageView(CustomImageModel(image: item.image))
///                     .aspectRatio(contentMode: .fill)
///             }
///         )
///     }
/// }
/// ```
///
/// - Important: Requires **iOS 18** because it relies on
///   `onScrollGeometryChange`. For earlier OS versions you can wrap the view
@available(iOS 18.0, *)
public struct SLAmbientCarouselLayout<Data: RandomAccessCollection, Content: View, BackdropContent: View>: View where Data.Element: Identifiable & SLImageModel {
    /// Visual & behavioural parameters supplied via protocol for easy theming.
    let config: any SLAmbientCarouselProtocol
    /// The collection of items displayed by the carousel.
    let items:  Data
    /// Foreground (front-most) cell builder.
    let content: (Data.Element) -> Content
    /// Blurred backdrop cell builder.
    let backdropContent: (Data.Element) -> BackdropContent
    /// Horizontal progress of the items in scroll view 0 … n-1
    @State private var scrollProgressX: CGFloat = 0
    
    // MARK: Initialiser
    public init(config: some SLAmbientCarouselProtocol,
                items:  Data,
                content: @escaping (Data.Element) -> Content,
                backdropContent: @escaping (Data.Element) -> BackdropContent) {
        self.config = config
        self.items = items
        self.content = content
        self.backdropContent = backdropContent
    }

    public var body: some View {
        carouselView()
    }
    
    /// The main carousel with built-in paging & backdrop.
    @ViewBuilder
    private func carouselView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: config.itemSpacing) {
                ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
                    content(item)
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: config.frameHeight)
        .background(backDropCarouselView())
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .onScrollGeometryChange(for: CGFloat.self) {
            let offsetX = $0.contentOffset.x + $0.contentInsets.leading
            let width = $0.contentSize.width + config.itemSpacing
            
            return offsetX / width
        } action: { oldValue, newValue in
            let maxValue = CGFloat(items.count - 1)
            scrollProgressX = min(max(newValue, 0), maxValue) * CGFloat(items.count)
        }

    }
    
    @ViewBuilder
    private func backDropCarouselView() -> some View {
        GeometryReader {
            let size = $0.size
            let array = Array(items)
            ZStack {
                ForEach(array.indices.reversed(), id: \.self) { index in
                    let item = array[index]
                    
                    backdropContent(item)
                        .frame(width: size.width, height: size.height)
                        .clipped()
                        .opacity(slideOpacity(for: index))
                }
            }
            .compositingGroup()
            .blur(radius: config.backgroundBlurRadius, opaque: true)
            .overlay {
                Rectangle()
                    .fill(.black.opacity(config.backgroundBlurDarkness))
            }
            .mask(gradientMask)
        }
        .containerRelativeFrame(.horizontal)
        .padding(.bottom, -config.visibleBottomBlur)
        .padding(.top, -config.visibleTopBlur)
    }
    
    /// Linear opacity falloff: 1 for centred slide → 0 when ≥ 1 position away.
    private func slideOpacity(for index: Int) -> Double {
        let delta = abs(self.scrollProgressX - CGFloat(index))
        return Double(max(0, 1 - delta))
    }
    
    /// Vertical fade-out so the backdrop blends into the surrounding UI.
    private var gradientMask: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .black,
                        .black,
                        .black,
                        .black,
                        .black.opacity(0.5),
                        .clear
                    ],
                    startPoint: .top, endPoint: .bottom)
            )
    }
}
