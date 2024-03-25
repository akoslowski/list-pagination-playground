import SwiftUI

struct DetailView: View {
    init(index: Int, text: String, tint: Binding<Color>) {
        self.index = index
        self.text = text
        self._tint = tint
    }

    let index: Int
    let text: String
    @Binding var tint: Color

    var body: some View {
        ZStack {
            Color.clear
                .background(
                    Gradient(
                        colors: [
                            rowBackgroundColor(at: index - 4),
                            rowBackgroundColor(at: index),
                            rowBackgroundColor(at: index + 4)
                        ]
                    )
                )
                .ignoresSafeArea()

            Text(text)
                .font(
                    .system(
                        size: 50,
                        weight: .heavy,
                        design: .monospaced
                    )
                )
                .foregroundStyle(
                    contrastingTextColor(at: index)
                )
        }
        .onAppear {
            tint = contrastingTextColor(at: index)
        }
    }
}

// MARK: - Previews -

#Preview("dark text") {
    DetailView(
        index: 20,
        text: "Hello World!",
        tint: .constant(.white)
    )
}

#Preview("light text") {
    DetailView(
        index: 57,
        text: "Hello World!",
        tint: .constant(.white)
    )
}
