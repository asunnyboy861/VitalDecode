import SwiftUI

struct CategoryHeader: View {
    let title: String
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
            Spacer()
        }
        .padding(.top, 8)
    }
}
