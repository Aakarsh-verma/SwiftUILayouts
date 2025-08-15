//
//  SLImageView.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 15/08/25.
//

import SwiftUI
import Kingfisher

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
