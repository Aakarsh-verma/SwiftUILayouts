//
//  SLImageModel.swift
//  LayoutsSample
//
//  Created by Aakarsh Verma on 14/08/25.
//

import SwiftUI

/// A protocol representing a generic image model that can be used across SwiftUI layouts.
/// Conforming types provide information about the image resource  and an optional placeholder.
/// This abstraction allows uniform handling of local asset images and remote image URLs.
@available(iOS 13.0, *)
public protocol SLImageModel {    
    /// The image source. This can be a remote URL string (http/https) or a local asset name.
    var image: String { get }
    
    /// An optional placeholder image name to be displayed while the main image is loading or unavailable.
    var placeHolderImage: String? { get }
}

/// Extension providing convenience properties for `SLImageModel`.
/// These computed properties help distinguish between remote image URLs and local asset images.
@available(iOS 13.0, *)
extension SLImageModel {
    /// Indicates whether the image source is a remote URL (http/https).
    /// Use this to determine if network fetching is required.
    public var isRemoteImage: Bool {
        return image.hasPrefix("http") || image.hasPrefix("https")
    }
    
    /// Indicates whether the image source corresponds to a valid local asset in the app bundle.
    /// Returns `true` if the asset can be found in the main bundle, otherwise `false`.
    public var isAssetImage: Bool {
        return UIImage(named: image) != nil
    }
}
