////
////  ImageLoader.swift
////  Unizo_iOS
////
////  Created by Nishtha on 18/01/26.
////
//
//import UIKit
//
//final class ImageLoader {
//
//    static let shared = ImageLoader()
//
//    private let cache = NSCache<NSString, UIImage>()
//
//    private init() {}
//
//    func load(
//        _ urlString: String?,
//        into imageView: UIImageView,
//        placeholder: UIImage? = UIImage(named: "placeholder")
//    ) {
//        imageView.image = placeholder
//
//        guard
//            let urlString = urlString,
//            let url = URL(string: urlString)
//        else {
//            return
//        }
//
//        // ✅ Cached image
//        if let cachedImage = cache.object(forKey: urlString as NSString) {
//            imageView.image = cachedImage
//            return
//        }
//
//        // ✅ Download image
//        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            guard
//                let self = self,
//                let data = data,
//                let image = UIImage(data: data),
//                error == nil
//            else {
//                return
//            }
//
//            self.cache.setObject(image, forKey: urlString as NSString)
//
//            DispatchQueue.main.async {
//                imageView.image = image
//            }
//        }.resume()
//    }
//}
