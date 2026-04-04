//
//  UIImageView+Load.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import UIKit

private let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {

    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder

        // Validate URL before attempting network request.
        // Firestore documents may contain invalid URLs like "banner1" instead of
        // "https://..." — attempting to load these crashes with NSURLErrorDomain -1002.
        guard !urlString.isEmpty,
              urlString.hasPrefix("http://") || urlString.hasPrefix("https://"),
              let url = URL(string: urlString) else {
            if !urlString.isEmpty {
                print("⚠️ ImageLoader: Invalid or non-http URL skipped: '\(urlString)'")
            }
            // Keep placeholder image
            return
        }

        // Check cache first
        if let cached = imageCache.object(forKey: urlString as NSString) {
            self.image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("⚠️ ImageLoader: Failed to load \(urlString): \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let image = UIImage(data: data) else { return }

            imageCache.setObject(image, forKey: urlString as NSString)

            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
