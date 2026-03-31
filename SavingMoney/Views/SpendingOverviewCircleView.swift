import SwiftUI

struct SpendingOverviewCircleView: View {
    let categoryPercents: [(category: String, percent: Double, color: Color)]
 
    var body: some View {
        VStack {
            Text(LocalizationKeys.spendingBreakdown.localized)
                .font(.headline)
                .padding(.bottom, 8)
          Spacer()
         
          Spacer()
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 32)
                    .frame(width: 180, height: 180)
                PieChart(percentData: categoryPercents)
                    .frame(width: 180, height: 180)
            }
          Spacer()
            HStack {
                ForEach(categoryPercents, id: \ .category) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        Text(item.category)
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 8)
          Spacer()
        }
    }
}

struct PieChart: View {
    let percentData: [(category: String, percent: Double, color: Color)]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<percentData.count, id: \ .self) { i in
                    PieSlice(startAngle: angle(at: i), endAngle: angle(at: i + 1), color: percentData[i].color)
                }
            }
        }
    }
    
    private func angle(at index: Int) -> Angle {
        let total = percentData.reduce(0) { $0 + $1.percent }
        let percent = percentData.prefix(index).reduce(0) { $0 + $1.percent }
        return Angle(degrees: percent / max(total, 1) * 360)
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 90, y: 90)
            path.move(to: center)
            path.addArc(center: center, radius: 90, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
        .fill(color)
    }
}

// Preview with sample data
struct SpendingOverviewCircleView_Previews: PreviewProvider {
    static var previews: some View {
        SpendingOverviewCircleView(categoryPercents: [
            ("Food", 0.4, .orange),
            ("Transport", 0.2, .blue),
            ("Shopping", 0.15, .purple),
            ("Bills", 0.25, .gray)
        ])
    }
}
