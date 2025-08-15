//
//  ImageModel.swift
//  LayoutsSample
//
//  Created by Aakarsh Verma on 14/08/25.
//

import SwiftUI
import Kingfisher

@available(iOS 13.0, *)
public protocol CustomImageModel {
    var id: UUID { get }
    var image: String { get }
    var placeHolderImage: String? { get }
}

@available(iOS 13.0, *)
extension CustomImageModel {
    public var isRemoteImage: Bool {
        return image.hasPrefix("http") || image.hasPrefix("https")
    }
    
    public var isAssetImage: Bool {
        return UIImage(named: image) != nil
    }
}

@available(iOS 15.0, *)
public struct CustomImageView: View {
    public var imageModel: CustomImageModel
    
    public init(_ imageModel: CustomImageModel) {
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

//public struct CustomImageModel: Identifiable, Hashable, Encodable, Decodable {
//    public var id: UUID = UUID()
//    public var image: String
//    
//    var isRemoteImage: Bool {
//        return image.hasPrefix("http") || image.hasPrefix("https")
//    }
//    
//    public var isAssetImage: Bool {
//        return UIImage(named: image) != nil
//    }
//    
//    public init(for image: String) {
//        self.image = image
//    }
//}
