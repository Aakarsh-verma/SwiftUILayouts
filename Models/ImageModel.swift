//
//  ImageModel.swift
//  LayoutsSample
//
//  Created by Aakarsh Verma on 14/08/25.
//

import SwiftUI

public struct ImageModel: Identifiable {
    var id: UUID = UUID()
    public var image: String
    
    public init(image: String) {
        self.image = image
    }
}

struct CustomImageView: View {
    var imageModel: CustomImageModel
    
    var body: some View {
        if imageModel.isAssetImage {
            Image(imageModel.image)
                .resizable()
        } else {
            Image(systemName: imageModel.image)
                .resizable()
        }
    }
}

struct CustomImageModel: Identifiable, Hashable, Encodable, Decodable {
    var id: UUID = UUID()
    var image: String
    
//    var isRemoteImage: Bool {
//        return image.hasPrefix("http") || image.hasPrefix("https")
//    }
    
    var isAssetImage: Bool {
        return UIImage(named: image) != nil
    }
    
    init(for image: String) {
        self.image = image
    }
}
