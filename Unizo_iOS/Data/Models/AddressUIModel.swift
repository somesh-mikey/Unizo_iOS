//
//  AddressUIModel.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation
import FirebaseFirestore

struct AddressUIModel {
    @DocumentID var id: String?
    let nameLine: String
    let addressText: String
    let isDefault: Bool
}

