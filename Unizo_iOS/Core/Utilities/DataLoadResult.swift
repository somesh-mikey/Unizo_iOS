//
//  DataLoadResult.swift
//  Unizo_iOS
//
//  Standardized result type for data loading operations.
//  Use this to categorize load failures consistently across view controllers,
//  enabling unified error handling and user-facing messaging.
//

import Foundation

enum DataLoadResult<T> {
    case success(T)
    case empty                // Query succeeded, 0 results
    case networkUnavailable   // NetworkError.noConnection
    case authFailure          // User not authenticated
    case schemaError(Error)   // Decode failure or query structure error
    case unknown(Error)       // Any other error

    /// Converts a thrown error into a categorized `DataLoadResult`.
    static func from(_ error: Error) -> DataLoadResult<T> {
        if case NetworkError.noConnection = error {
            return .networkUnavailable
        }

        let nsError = error as NSError
        if nsError.code == 401 {
            return .authFailure
        }

        if error is DecodingError {
            return .schemaError(error)
        }

        return .unknown(error)
    }

    /// User-facing message suitable for empty state labels.
    var userMessage: String {
        switch self {
        case .success:
            return ""
        case .empty:
            return "Nothing here yet."
        case .networkUnavailable:
            return "No internet connection.\nCheck your network and try again."
        case .authFailure:
            return "Please sign in to continue."
        case .schemaError:
            return "Something went wrong.\nPlease update the app or try again later."
        case .unknown:
            return "Couldn't load data.\nPull to retry."
        }
    }
}
