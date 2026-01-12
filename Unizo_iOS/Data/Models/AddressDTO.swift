//
//  AddressDTO.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation

struct AddressDTO: Codable {
    let id: UUID
    let user_id: UUID
    var name: String
    var phone: String
    var line1: String
    var city: String
    var state: String
    var postal_code: String
    var is_default: Bool
}



