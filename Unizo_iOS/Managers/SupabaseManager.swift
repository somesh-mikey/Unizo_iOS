//
//  SupabaseManager.swift
//  Unizo_iOS
//
//  Created by Nishtha on 13/01/26.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://tcaqxwxlrfoxmthigjgd.supabase.co")!,
            supabaseKey: "sb_publishable_17MrI1DzB2mXj9mbzERurw_kXDz0tZi"
        )
    }
}
