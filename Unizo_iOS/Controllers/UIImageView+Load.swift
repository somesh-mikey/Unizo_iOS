//
//  UIImageView+Load.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import UIKit

extension UIImageView {

    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}

