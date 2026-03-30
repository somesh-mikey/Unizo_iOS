//
//  UserDTO.swift
//  Unizo_iOS
//

import Foundation

struct UserDTO: Codable {
    let id: UUID
    var first_name: String?
    var last_name: String?
    var email: String?
    var phone: String?
    var role: String?
    var date_of_birth: String?
    var gender: String?
    var profile_image_url: String?
    var email_notifications: Bool?
    var sms_notifications: Bool?
    var created_at: String?

    // Computed property for display name
    var displayName: String {
        let first = first_name ?? ""
        let last = last_name ?? ""
        let fullName = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        return fullName.isEmpty ? "User" : fullName
    }
}

// For updating user preferences
struct UserPreferencesUpdate: Encodable {
    var email_notifications: Bool?
    var sms_notifications: Bool?
}

// For updating user profile
struct UserProfileUpdate: Encodable {
    var first_name: String?
    var last_name: String?
    var phone: String?
    var date_of_birth: String?
    var gender: String?
    var profile_image_url: String?
}
