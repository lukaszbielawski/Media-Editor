//
//  FlieError.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Foundation

enum FileError: Error {
    case documentDirectory
    case subdirectory
    case store(url: URL)
    case unknown
}

extension FileError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .documentDirectory:
            return "Couldn't access document directory"
        case .subdirectory:
            return "Couldn't create subdirectory"
        case .store(let url):
            return "Couldn't store file properly at \(url)"
        case .unknown:
            return "An unknown error occured"
        }
    }
}
