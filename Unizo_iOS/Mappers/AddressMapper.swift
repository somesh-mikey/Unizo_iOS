//
//  AddressMapper.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation

enum AddressMapper {
    static func toUI(_ dto: AddressDTO) -> AddressUIModel {
        AddressUIModel(
            id: dto.id,
            nameLine: "\(dto.name)   \(dto.phone)",
            addressText: "\(dto.line1),\n\(dto.city), \(dto.state) \(dto.postal_code)",
            isDefault: dto.is_default
        )
    }
}

