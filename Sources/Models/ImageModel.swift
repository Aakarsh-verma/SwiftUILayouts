//
//  ImageModel.swift
//  LayoutsSample
//
//  Created by Aakarsh Verma on 14/08/25.
//

import SwiftUI
import Kingfisher

@available(iOS 13.0, *)
public protocol SLImageModel {
    var id: UUID { get }
    var image: String { get }
    var placeHolderImage: String? { get }
}

@available(iOS 13.0, *)
extension SLImageModel {
    public var isRemoteImage: Bool {
        return image.hasPrefix("http") || image.hasPrefix("https")
    }
    
    public var isAssetImage: Bool {
        return UIImage(named: image) != nil
    }
}

@available(iOS 15.0, *)
public struct SLImageView: View {
    public var imageModel: SLImageModel
    
    public init(_ imageModel: SLImageModel) {
        self.imageModel = imageModel
    }
    
    public var body: some View {
        if imageModel.isRemoteImage {
            KFImage(URL(string: imageModel.image)!)
                .placeholder {
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
