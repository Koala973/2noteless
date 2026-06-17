import SwiftUI

struct HomeFeedView: View {
    private let cards = QuestCard.samples

    var body: some View {
        ZStack {
            DoodlePalette.paperBg
                .ignoresSafeArea()
                .messyScribbleBackground(color: DoodlePalette.bubblegumPink, opacity: 0.06)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HomeHeaderView()
                        .padding(.top, 18)

                    LazyVStack(spacing: 16) {
                        ForEach(cards) { card in
                            QuestCardView(card: card)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            DoodleActionBar(showsRecordButton: false)
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
                .background {
                    DoodlePalette.paperBg
                        .ignoresSafeArea(edges: .bottom)
                }
        }
        .overlay {
            RecordingHUDView()
        }
    }
}

private struct HomeHeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            MrMessyPlaceholder()

            Text("THE MESS")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(DoodlePalette.markerBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.66)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
    }
}

private struct MrMessyPlaceholder: View {
    var body: some View {
        ZStack {
            Color.white

            Canvas { context, size in
                for index in 0..<10 {
                    let progress = CGFloat(index) / 10
                    let width = size.width * (0.42 + 0.18 * sin(progress * .pi * 4))
                    let height = size.height * (0.28 + 0.12 * cos(progress * .pi * 3))
                    let x = size.width * (0.18 + 0.64 * progress)
                    let y = size.height * (0.42 + 0.18 * sin(progress * .pi * 2))
                    let rect = CGRect(x: x - width / 2, y: y - height / 2, width: width, height: height)
                    context.stroke(
                        Path(ellipseIn: rect),
                        with: .color(DoodlePalette.bubblegumPink),
                        lineWidth: 2.4
                    )
                }
            }
            .padding(5)

            VStack(spacing: 1) {
                Text("MR.")
                    .font(.system(size: 5, weight: .black, design: .rounded))
                Spacer(minLength: 0)
                Image(systemName: "face.smiling.inverse")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(DoodlePalette.markerBlack)
                    .padding(.bottom, 4)
            }
            .foregroundStyle(DoodlePalette.markerBlack)
            .padding(.top, 4)
        }
        .frame(width: 44, height: 44)
        .doodleBorder(Rectangle(), lineWidth: 3)
        .accessibilityLabel("Mr. Messy placeholder avatar")
    }
}

#Preview("iPhone 13 mini layout") {
    HomeFeedView()
        .frame(width: 375, height: 812)
}

#Preview("iPhone 17 Pro Max layout") {
    HomeFeedView()
        .frame(width: 440, height: 956)
}
