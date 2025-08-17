//
//  SLImageView.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 15/08/25.
//

import SwiftUI
import Kingfisher

/// A SwiftUI view that displays an image based on a provided `SLImageModel`.
/// - Supports rendering images from three possible sources:
///   1. Remote URLs (using Kingfisher's `KFImage`).
///   2. Local asset catalog images.
///   3. System images (SF Symbols).
/// - Optionally displays a placeholder image when loading remote images.
@available(iOS 15.0, *)
public struct SLImageView: View {
    /// The image model containing information about the image source and optional placeholder.
    public var imageModel: SLImageModel
    /// Initializes the view with an image model.
    /// - Parameter imageModel: The model representing the image to display.
    public init(_ imageModel: SLImageModel) {
        self.imageModel = imageModel
    }
    /// The body of the view. Dynamically selects the rendering method:
    /// - Uses `KFImage` for remote URLs with a placeholder if provided.
    /// - Uses `Image` for local asset images.
    /// - Defaults to `Image(systemName:)` for SF Symbols or unknown cases.
    public var body: some View {
        if imageModel.isRemoteImage {
            KFImage(URL(string: imageModel.image)!)
                .placeholder {
                    // If a placeholder image is provided, display it.
                    // Otherwise, fall back to a gray system "photo" icon.
                    if let placeholderImage = imageModel.placeHolderImage {
                        Image(placeholderImage)
                    } else {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.gray)
                    }
                }
                .resizable()
        } else if imageModel.isAssetImage {
            Image(imageModel.image)
                .resizable()
        } else {
            Image(systemName: imageModel.image)
                .resizable()
        }
    }
}
