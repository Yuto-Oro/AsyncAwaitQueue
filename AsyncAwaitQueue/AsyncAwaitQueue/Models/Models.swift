//
//  Models.swift
//  AsyncAwaitQueue
//
//  Created by Orlando Ortega on 04/10/21.
//

import UIKit

struct ImageMetadata: Codable {
    let name: String
    let firstAppearance: String
    let year: Int
}

struct DetailedImage {
    let image: UIImage
    let metadata: ImageMetadata
}

enum ImageDownloadError: Error {
    case badImage
    case invalidMetadata
}
