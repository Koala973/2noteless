import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct DoodleActionBar: View {
    var showsRecordButton: Bool = true
    private var isRecording: Binding<Bool>?
    private var namespace: Namespace.ID?
    var onShop: () -> Void = {}
    var onRecord: () -> Void = {}
    var onWrite: () -> Void = {}

    init(
        showsRecordButton: Bool = true,
        onShop: @escaping () -> Void = {},
        onRecord: @escaping () -> Void = {},
        onWrite: @escaping () -> Void = {}
    ) {
        self.showsRecordButton = showsRecordButton
        self.isRecording = nil
        self.namespace = nil
        self.onShop = onShop
        self.onRecord = onRecord
        self.onWrite = onWrite
    }

    init(
        isRecording: Binding<Bool>,
        namespace: Namespace.ID,
        onShop: @escaping () -> Void = {},
        onWrite: @escaping () -> Void = {}
    ) {
        self.showsRecordButton = true
        self.isRecording = isRecording
        self.namespace = namespace
        self.onShop = onShop
        self.onRecord = {}
        self.onWrite = onWrite
    }

    var body: some View {
        HStack(alignment: .center) {
            Button(action: onShop) {
                Image(systemName: "bag.fill")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(DoodlePalette.markerBlack)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(
                BrutalButtonStyle(
                    fillColor: .white,
                    foregroundColor: DoodlePalette.markerBlack,
                    borderWidth: 3,
                    shadowOffset: CGSize(width: 4, height: 4),
                    shape: .circle,
                    haptic: .light
                )
            )
            .tint(DoodlePalette.markerBlack)
            .accessibilityLabel("Shop")

            Spacer(minLength: 26)

            recordButton

            Spacer(minLength: 26)

            Button(action: onWrite) {
                Image(systemName: "square.and.pencil")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(DoodlePalette.markerBlack)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(
                BrutalButtonStyle(
                    fillColor: .white,
                    foregroundColor: DoodlePalette.markerBlack,
                    borderWidth: 3,
                    shadowOffset: CGSize(width: 4, height: 4),
                    shape: .circle,
                    haptic: .light
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

    @ViewBuilder
    private var recordButton: some View {
        if showsRecordButton {
            if let isRecording, let namespace {
                DoodleActionRecordButton(isRecording: isRecording, namespace: namespace)
            } else {
                Button(action: onRecord) {
                    Image(systemName: "mic.fill")
                        .symbolRenderingMode(.monochrome)
                        .font(.system(size: 25, weight: .black))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(
                    BrutalButtonStyle(
                        fillColor: DoodlePalette.brutalPink,
                        foregroundColor: .white,
                        borderWidth: 4,
                        shadowOffset: CGSize(width: 4, height: 4),
                        shape: .circle,
                        haptic: .heavy
                    )
                )
                .tint(.white)
                .accessibilityLabel("Start recording")
            }
        } else {
            Color.clear
                .frame(width: 56, height: 56)
                .accessibilityHidden(true)
        }
    }
}

private struct DoodleActionRecordButton: View {
    @Binding var isRecording: Bool
    let namespace: Namespace.ID

    var body: some View {
        ZStack {
            if isRecording {
                Color.clear
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)
            } else {
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    #endif
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                        isRecording = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(DoodlePalette.brutalPink)
                            .overlay {
                                Circle()
                                    .stroke(DoodlePalette.markerBlack, lineWidth: 4)
                            }
                            .matchedGeometryEffect(id: "micButton", in: namespace)

                        Image(systemName: "mic.fill")
                            .symbolRenderingMode(.monochrome)
                            .font(.system(size: 25, weight: .black))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 56, height: 56)
                    .contentShape(Circle())
                }
                .buttonStyle(
                    BrutalMicButtonStyle(
                        shadowOffset: CGSize(width: 4, height: 4),
                        pressedOffset: CGSize(width: 4, height: 4),
                        haptic: .heavy
                    )
                )
                .tint(.white)
                .accessibilityLabel("Start recording")
                .accessibilityIdentifier("recordingHUD.startButton")
            }
        }
        .frame(width: 56, height: 56)
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
