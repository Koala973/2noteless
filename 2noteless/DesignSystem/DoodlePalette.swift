import SwiftUI

enum DoodlePalette {
    static let paperBg = Color("PaperBg")
    static let markerBlack = Color("MarkerBlack")
    static let bubblegumPink = Color("BubblegumPink")
    static let brutalPink = Color(.displayP3, red: 1.0, green: 0.20, blue: 0.60, opacity: 1.0)
    static let highVisYellow = Color("HighVisYellow")
}

enum DoodleTypography {
    static func largeTitle(size: CGFloat = 34) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    static func title(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    static func body(size: CGFloat = 16, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}
