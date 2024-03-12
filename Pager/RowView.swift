import SwiftUI

struct RowView: View {

    let index: Int
    let content: String

    private func rowBackgroundColor(at index: Int) -> Color {
        Color(
            hue: Double(index % 100)/100,
            saturation: 1.0,
            brightness: 1.0
        )
    }

    var body: some View {
        LabeledContent {
            Text(content).monospaced()
        } label: {
            Text("\(index, format: .number)").bold()
        }
        .padding(.vertical, 8)
        .foregroundStyle(rowBackgroundColor(at: index).contrasting(contrastRatio: 4.5))
        .listRowBackground(rowBackgroundColor(at: index))
    }
}

// MARK: - Previews -

#Preview {
    List {
        Section {
            RowView(index: 0, content: "Hello")
            RowView(index: 5, content: "World!")
            RowView(index: 10, content: "How")
            RowView(index: 15, content: "Are")
            RowView(index: 20, content: "You?")
        }
        
        ForEach(100...300, id: \.self) {
            RowView(index: $0, content: "😃")
        }
    }
}
