//
//  String.swift
//  Folium-tvOS
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import CryptoKit
import Foundation

extension String {
    static func nonce(with length: Int = 32) -> String {
        precondition(length > 0)
        
        var bytes = [UInt8](repeating: 0, count: length)
        
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        switch errorCode {
        case errSecSuccess:
            print("\(#function): success")
        default:
            print("\(#function): failed")
        }
        
        let charset: [Character] = .init("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = bytes.map { charset[Int($0) % charset.count] }
        
        return .init(nonce)
    }
    
    static func sha256(from input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { .init(format: "%02x", $0) }.joined()
        
        return hashString
    }
}
