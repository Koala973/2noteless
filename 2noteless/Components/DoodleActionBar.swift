import SwiftUI

struct DoodleActionBar: View {
    var showsRecordButton: Bool = true
    var onShop: () -> Void = {}
    var onRecord: () -> Void = {}
    var onWrite: () -> Void = {}

    var body: some View {
        HStack(alignment: .center) {
            Button(action: onShop) {
                Image(systemName: "bag.fill")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(DoodlePalette.markerBlack)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(
                DoodlePressButtonStyle(
                    fillColor: .white,
                    foregroundColor: DoodlePalette.markerBlack,
                    shadowOffset: 2
                )
            )
            .tint(DoodlePalette.markerBlack)
            .accessibilityLabel("Shop")

            Spacer(minLength: 26)

            if showsRecordButton {
                Button(action: onRecord) {
                    Image(systemName: "mic.fill")
                        .symbolRenderingMode(.monochrome)
                        .font(.system(size: 25, weight: .black))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(
                    DoodlePressButtonStyle(
                        fillColor: DoodlePalette.bubblegumPink,
                        foregroundColor: .white,
                        borderWidth: 4,
                        shadowOffset: 4
                    )
                )
                .tint(.white)
                .accessibilityLabel("Start recording")
            } else {
                Color.clear
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)
            }

            Spacer(minLength: 26)

            Button(action: onWrite) {
                Image(systemName: "square.and.pencil")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(DoodlePalette.markerBlack)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(
                DoodlePressButtonStyle(
                    fillColor: .white,
                    foregroundColor: DoodlePalette.markerBlack,
                    shadowOffset: 2
                )
            )
            .tint(DoodlePalette.markerBlack)
            .accessibilityLabel("Write note")
        }
        .padding(.horizontal, 22)
        .frame(height: 72)
        .foregroundColor(DoodlePalette.markerBlack)
        .tint(DoodlePalette.markerBlack)
        .background {
            Capsule()
                .fill(Color.white)
                .overlay {
                    Capsule()
                        .stroke(DoodlePalette.markerBlack, lineWidth: 4)
                }
                .brutalShadow(color: DoodlePalette.markerBlack, x: 5, y: 5)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

#Preview {
    ZStack {
        DoodlePalette.paperBg.ignoresSafeArea()
        VStack {
            Spacer()
            DoodleActionBar()
        }
    }
}
