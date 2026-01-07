//
//  Session.swift
//  Unizo_iOS
//
//  Created by Somesh on 04/01/26.
//

import Foundation

enum Session {

    static let userId: UUID = {
        let key = "local_user_id"

        if let saved = UserDefaults.standard.string(forKey: key),
           let uuid = UUID(uuidString: saved) {
            return uuid
        }

        let new = UUID()
        UserDefaults.standard.set(new.uuidString, forKey: key)
        return new
    }()
}

