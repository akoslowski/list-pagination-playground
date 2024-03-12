import SwiftUI

struct ErrorView: View {
    let error: Error

    var body: some View {
        Group {
            Color.clear.background(.ultraThinMaterial)
            Text("\(error.localizedDescription) \n\nTap to retry.")
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 25.0).foregroundStyle(.red)
                )
        }
    }
}

#Preview {
    ErrorView(error: URLError(.badURL))
}
