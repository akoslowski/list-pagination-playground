import SwiftUI

func contrastingTextColor(at index: Int) -> Color {
    rowBackgroundColor(at: index)
        .contrasting(contrastRatio: 4.5)
}

func rowBackgroundColor(at index: Int) -> Color {
    Color(
        hue: Double(index % 100)/100,
        saturation: 1.0,
        brightness: 1.0
    )
}

extension Color {
    /**
     Here's how it works:
     - The contrasting method is an extension on Color that takes a contrastRatio parameter (default is 4.5, which is the minimum recommended contrast ratio for normal text).
     - The contrasting method calculates the luminance of the background color using the luminance method, which follows the formula for calculating relative luminance as per the WCAG 2.0 guidelines.
     - Based on the luminance and the desired contrast ratio, the contrasting method determines if the foreground color should be white or black for optimal readability.
     - The Text view is styled with the background color and the contrasting foreground color.

     Created with Claude 3 Sonnet: https://claude.ai/chat/542af914-751d-441d-8c61-12abb1130070
     */
    func contrasting(contrastRatio: Double) -> Color {
        let contrastRatio = contrastRatio > 1 ? contrastRatio : 1 / contrastRatio
        let luminance = luminance()
        let targetLuminance = luminance > 0.5 ? (luminance + 0.05) / contrastRatio : (luminance + 0.05) * contrastRatio
        return targetLuminance > luminance ? .white : .black
    }

    /// See https://www.w3.org/TR/WCAG20/#relativeluminancedef
    private func luminance() -> Double {
        let rgb = cgColor?.components?.map { $0 < 0 ? 0 : $0 } ?? [0, 0, 0]
        let r = rgb[0]
        let g = rgb[1]
        let b = rgb[2]
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
}
