//  Unizo_iOS
//
//  Created by Soham Bhattacharya on 21/01/26.
//

import Foundation

struct ProductInsertDTO: Encodable {
    let title: String
    let description: String
    let price: Int
    let image_url: String
    let is_negotiable: Bool
    let views_count: Int
    let is_active: Bool
    let rating: Int
    let colour: String
    let category: String
    let size: String
    let condition: String
}
