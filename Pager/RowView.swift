import SwiftUI

struct RowView: View {

    let index: Int
    let content: String

    var body: some View {
        LabeledContent {
            Text(content).monospaced()
        } label: {
            Text("\(index, format: .number)").bold()
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8)
        .foregroundStyle(contrastingTextColor(at: index))
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
