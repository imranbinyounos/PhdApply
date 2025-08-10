//
//  Utilities.swift
//  PhdApply
//
//  Created by Assistant on 9/8/25.
//

import Foundation
import SwiftUI
import AppKit

// MARK: - Color <-> Hex

extension Color {
    init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6 || hexString.count == 8 else { return nil }

        var rgba: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgba) else { return nil }

        let hasAlpha = hexString.count == 8
        let r = Double((rgba & 0xFF000000) >> 24) / 255.0
        let g = Double((rgba & 0x00FF0000) >> 16) / 255.0
        let b = Double((rgba & 0x0000FF00) >> 8) / 255.0
        let a = hasAlpha ? Double(rgba & 0x000000FF) / 255.0 : 1.0

        self = Color(red: r, green: g, blue: b, opacity: a)
    }

    func toHex(includeAlpha: Bool = false) -> String? {
        #if os(macOS)
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else { return nil }
        let r = Int(round(rgbColor.redComponent * 255))
        let g = Int(round(rgbColor.greenComponent * 255))
        let b = Int(round(rgbColor.blueComponent * 255))
        if includeAlpha {
            let a = Int(round(rgbColor.alphaComponent * 255))
            return String(format: "%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "%02X%02X%02X", r, g, b)
        }
        #else
        return nil
        #endif
    }
}

// MARK: - Date Helpers

extension Date {
    func formattedDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: self)
    }

    static func days(from start: Date, to end: Date) -> Int? {
        let calendar = Calendar.current
        let s = calendar.startOfDay(for: start)
        let e = calendar.startOfDay(for: end)
        return calendar.dateComponents([.day], from: s, to: e).day
    }
}

// MARK: - URL Helpers

extension URL {
    static func from(_ string: String) -> URL? {
        guard let url = URL(string: string) else { return nil }
        if url.scheme == nil { return URL(string: "https://\(string)") }
        return url
    }
}

// MARK: - AppStorage Keys

enum AppStorageKeys {
    static let shownColumns = "shownColumns.v1"
    static let professorColumns = "professorColumns.v1"
    static let universityColumns = "universityColumns.v1"
}


