import SwiftUI

struct RangeBarView: View {
    let value: Double
    let refLow: Double
    let refHigh: Double
    let optLow: Double
    let optHigh: Double
    let statusColor: Color

    private var valuePosition: CGFloat {
        let range = refHigh - refLow
        guard range > 0 else { return 0.5 }
        let margin = range * 0.15
        let totalRange = range + 2 * margin
        let position = (value - (refLow - margin)) / totalRange
        return CGFloat(max(0, min(1, position)))
    }

    private var optStart: CGFloat {
        let range = refHigh - refLow
        guard range > 0 else { return 0.3 }
        let margin = range * 0.15
        let totalRange = range + 2 * margin
        return CGFloat((optLow - (refLow - margin)) / totalRange)
    }

    private var optEnd: CGFloat {
        let range = refHigh - refLow
        guard range > 0 else { return 0.7 }
        let margin = range * 0.15
        let totalRange = range + 2 * margin
        return CGFloat((optHigh - (refLow - margin)) / totalRange)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.green.opacity(0.3))
                    .frame(height: 8)
                    .frame(width: geo.size.width * (optEnd - optStart))
                    .offset(x: geo.size.width * optStart)

                Circle()
                    .fill(statusColor)
                    .frame(width: 14, height: 14)
                    .overlay {
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                    }
                    .shadow(color: statusColor.opacity(0.4), radius: 3)
                    .offset(x: geo.size.width * valuePosition - 7)
            }
        }
        .frame(height: 14)
    }
}
