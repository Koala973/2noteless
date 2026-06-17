import SwiftUI

struct QuestCard: Identifiable {
    let id = UUID()
    let tag: String
    let title: String
    let time: String
    let body: String
    let rotationDegrees: Double

    static let samples: [QuestCard] = [
        QuestCard(
            tag: "IDEA",
            title: "Brand doodles exploration",
            time: "9:12 AM",
            body: "Playing with messy characters and bold type while keeping every sentence readable.",
            rotationDegrees: -1.2
        ),
        QuestCard(
            tag: "REMINDER",
            title: "Design sync with team",
            time: "Today, 2:00 PM",
            body: "Review the first Doodle-Brutalism pass before expanding the rest of the app.",
            rotationDegrees: 0.8
        ),
        QuestCard(
            tag: "THOUGHT",
            title: "Messy is not unclear",
            time: "8:47 AM",
            body: "The surface can be chaotic, but the information architecture has to stay calm.",
            rotationDegrees: -0.6
        ),
        QuestCard(
            tag: "SKETCH",
            title: "New character direction",
            time: "Yesterday",
            body: "Use the pink scribble avatar as a signal, not as a replacement for product clarity.",
            rotationDegrees: 1.1
        )
    ]
}

struct QuestCardView: View {
    let card: QuestCard
    @State private var tagRotation = Double.random(in: -3...3)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(card.title)
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .foregroundStyle(DoodlePalette.markerBlack)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: 8)

                Text(card.time)
                    .font(DoodleTypography.body(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(card.body)
                .font(DoodleTypography.body(size: 15, weight: .medium))
                .foregroundStyle(DoodlePalette.markerBlack)
                .lineLimit(3)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            DoodleTagView(label: card.tag, rotationDegrees: tagRotation)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(.white)
                .doodleBorder(RoundedRectangle(cornerRadius: 5, style: .continuous), lineWidth: 3)
                .brutalShadow(color: DoodlePalette.markerBlack, x: 4, y: 4)
                .rotationEffect(.degrees(card.rotationDegrees))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.tag), \(card.title), \(card.time), \(card.body)")
    }
}

private struct DoodleTagView: View {
    let label: String
    let rotationDegrees: Double

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(DoodlePalette.markerBlack)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(DoodlePalette.bubblegumPink.opacity(0.16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .stroke(DoodlePalette.markerBlack, lineWidth: 2)
                    }
                    .brutalShadow(color: DoodlePalette.markerBlack, x: 2, y: 2)
            }
            .rotationEffect(.degrees(rotationDegrees))
    }
}

#Preview {
    ZStack {
        DoodlePalette.paperBg.ignoresSafeArea()
        QuestCardView(card: QuestCard.samples[0])
            .padding(24)
    }
}
