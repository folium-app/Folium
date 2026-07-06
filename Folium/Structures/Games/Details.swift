//
//  GameDetails.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation

nonisolated
final class Details : Hashable, @unchecked Sendable {
    let id: UUID = UUID()
    let `extension`, name: String
    var size: String
    var url: URL
    
    init(url: URL) {
        let formatter: ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        `extension` = url.pathExtension.localizedLowercase
        name = url.deletingPathExtension()
            .lastPathComponent
            .replacingOccurrences(of: #"\s*\([^)]*\)"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let resourceValues: URLResourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            size = if let fileSize: Int = resourceValues.fileSize {
                formatter.string(fromByteCount: Int64(fileSize))
            } else {
                formatter.string(fromByteCount: 0)
            }
        } catch {
            size = formatter.string(fromByteCount: 0)
        }
        self.url = url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: borrowing Details, rhs: borrowing Details) -> Bool {
        lhs.id == rhs.id
    }
    
    var nameWithoutSpaces: String {
        name
            .replacingOccurrences(of: " ", with: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updateSize(with byteCount: Int) {
        let formatter: ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        size = formatter.string(fromByteCount: Int64(byteCount))
    }
}
