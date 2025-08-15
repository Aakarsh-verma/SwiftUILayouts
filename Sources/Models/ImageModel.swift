//
//  ImageModel.swift
//  LayoutsSample
//
//  Created by Aakarsh Verma on 14/08/25.
//

import SwiftUI

public struct ImageModel: Identifiable {
    public var id: UUID = UUID()
    public var image: String
    
    public init(image: String) {
        self.image = image
    }
}

@available(iOS 15.0, *)
public struct CustomImageView: View {
    public var imageModel: CustomImageModel
    
    public var body: some View {
        if imageModel.isAssetImage {
            Image(imageModel.image)
                .resizable()
        } else {
            Image(systemName: imageModel.image)
                .resizable()
        }
    }
}

public struct CustomImageModel: Identifiable, Hashable, Encodable, Decodable {
    public var id: UUID = UUID()
    public var image: String
    
//    var isRemoteImage: Bool {
//        return image.hasPrefix("http") || image.hasPrefix("https")
//    }
    
    public var isAssetImage: Bool {
        return UIImage(named: image) != nil
    }
    
    public init(for image: String) {
        self.image = image
    }
}
