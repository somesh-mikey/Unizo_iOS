//
//  SupabaseStorageService.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation

final class SupabaseStorageService {

    static let shared = SupabaseStorageService()

    private let supabaseURL = "https://tcaqxwxlrfoxmthigjgd.supabase.co"
    private let bucket = "product-images"

    private init() {}

    func publicImageURL(path: String) -> String {
        "\(supabaseURL)/storage/v1/object/public/\(bucket)/\(path)"
    }
}


