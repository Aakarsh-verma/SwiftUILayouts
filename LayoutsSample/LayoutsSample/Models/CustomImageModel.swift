//
//  CustomImageModel.swift
//  LayoutsSample
//
//  Created by Aakarsh Verma on 19/08/25.
//

import SwiftUI
import SwiftUILayouts

struct CustomImageModel: Identifiable, SLImageModel {
    var id = UUID()
    var image: String
    var placeHolderImage: String?
    
    init(image: String, 
         placeHolderImage: String? = nil) {
        self.image = image
        self.placeHolderImage = placeHolderImage
    }
}

var sampleImages: [CustomImageModel] = (1...9).compactMap { CustomImageModel(image: "m\($0)") }
