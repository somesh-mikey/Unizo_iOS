//
//  FirebaseStorageService.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation
import FirebaseStorage

final class FirebaseStorageService {

    static let shared = FirebaseStorageService()
    
    // Instead of using public static HTTP links like Supabase, Firebase Storage often provides
    // long lifespan download URLs asynchronously, but if you map directly to a path for 
    // ImageLoaders, you'd usually retrieve the URL reference.
    private let storage = Storage.storage()

    private init() {}

    /// Get a reference to a product image. In Firebase, you typically ask this reference for
    /// download URL async, rather than getting a synchronous string back. 
    /// For the time being, we provide a placeholder wrapper so compilation passes.
    func reference(forPath path: String) -> StorageReference {
        return storage.reference().child("product-images").child(path)
    }
    
    /// Async method to get the URL string if the app was previously relying on it 
    /// synchronously (this will require refactoring upstream usages).
    func fetchImageURL(path: String) async throws -> URL {
        return try await reference(forPath: path).downloadURL()
    }
}
