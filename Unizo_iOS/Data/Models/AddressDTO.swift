//
//  AddressDTO.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation
import FirebaseFirestore

struct AddressDTO: Codable {
    @DocumentID var id: String?
    let user_id: String
    var name: String
    var phone: String
    var line1: String
    var city: String
    var state: String
    var postal_code: String
    var country: String
    var is_default: Bool
}



