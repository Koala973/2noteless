import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct ExpandedRecordingHUD: View {
    @Binding var isRecording: Bool
    let namespace: Namespace.ID

    @State private var waveformScaleY: CGFloat = 1
    @State private var waveformNudgeX: CGFloat = 0
    @State private var meterIndex = 0

    private let waveformTimer = Timer.publish(every: 0.14, on: .main, in: .common).autoconnect()
    private let simulatedMeter: [(scaleY: CGFloat, nudgeX: CGFloat)] = [
        (0.92, -1.5), (1.18, 1.0), (0.84, -0.5), (1.34, 1.6), (1.02, -1.0),
        (1.26, 0.8), (0.88, -1.8), (1.40, 1.4), (1.08, 0.0), (0.96, -0.8)
    ]

    var body: some View {
        GeometryReader { proxy in
            let topOffset = RecordingHUDFigmaLayout.topOffset(for: proxy)
            let layout = RecordingHUDFigmaLayout(proxy: proxy, topOffset: topOffset)

            ZStack {
                DoodlePalette.paperBg
                    .ignoresSafeArea()

                Image("recording_hud_p4_base")
                    .resizable()
                    .frame(width: proxy.size.width, height: layout.contentHeight)
                    .position(x: proxy.size.width / 2, y: topOffset + layout.contentHeight / 2)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                Image("chaotic_waveform")
                    .resizable()
                    .scaledToFit()
                    .frame(width: layout.waveformSize.width, height: layout.waveformSize.height)
                    .scaleEffect(x: 1, y: waveformScaleY, anchor: .center)
                    .offset(x: waveformNudgeX)
                    .position(layout.waveformCenter)
                    .animation(.spring(response: 0.15, dampingFraction: 0.4, blendDuration: 0), value: waveformScaleY)
                    .animation(.spring(response: 0.15, dampingFraction: 0.4, blendDuration: 0), value: waveformNudgeX)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                hitZones(layout: layout)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .transition(.opacity)
        .onAppear(perform: resetWaveform)
        .onReceive(waveformTimer) { _ in
            guard isRecording else { return }
            meterIndex = (meterIndex + 1) % simulatedMeter.count
            let sample = simulatedMeter[meterIndex]
            waveformScaleY = sample.scaleY
            waveformNudgeX = sample.nudgeX
        }
    }

    private func hitZones(layout: RecordingHUDFigmaLayout) -> some View {
        ZStack {
            RecordingHUDHitZone(
                center: layout.topLeftCenter,
                size: layout.topButtonSize,
                accessibilityLabel: "Back",
                accessibilityIdentifier: "recordingHUD.backButton",
                action: close
            )

            RecordingHUDHitZone(
                center: layout.topRightCenter,
                size: layout.topButtonSize,
                accessibilityLabel: "More actions",
                accessibilityIdentifier: "recordingHUD.moreButton",
                action: moreFeedback
            )

            RecordingHUDHitZone(
                center: layout.micCenter,
                size: layout.micHitSize,
                accessibilityLabel: "Stop recording",
                accessibilityIdentifier: "recordingHUD.stopButton",
                action: close
            )
        }
    }

    private func close() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        #endif

        withAnimation(.easeOut(duration: 0.18)) {
            isRecording = false
        }
    }

    private func moreFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    private func resetWaveform() {
        waveformScaleY = 1
        waveformNudgeX = 0
        meterIndex = 0
    }
}

private struct RecordingHUDHitZone: View {
    let center: CGPoint
    let size: CGSize
    let accessibilityLabel: String
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Color.clear
                .frame(width: size.width, height: size.height)
                .contentShape(Rectangle())
        }
        .buttonStyle(RecordingHUDTransparentButtonStyle())
        .position(center)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

private struct RecordingHUDTransparentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.18, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

private struct RecordingHUDFigmaLayout {
    private static let canvasSize = CGSize(width: 786, height: 1418)
    private static let waveformRect = CGRect(x: -13, y: 398, width: 815, height: 528)
    private static let micRect = CGRect(x: 228, y: 932, width: 330, height: 330)
    private static let leftButtonRect = CGRect(x: 22, y: 84, width: 98, height: 98)
    private static let rightButtonRect = CGRect(x: 666, y: 84, width: 98, height: 98)

    private let scaleX: CGFloat
    private let scaleY: CGFloat
    private let originY: CGFloat
    let contentHeight: CGFloat

    static func topOffset(for proxy: GeometryProxy) -> CGFloat {
        proxy.safeAreaInsets.top > 55 ? 34 : 0
    }

    init(proxy: GeometryProxy, topOffset: CGFloat) {
        let viewSize = proxy.size
        scaleX = viewSize.width / Self.canvasSize.width
        contentHeight = max(1, viewSize.height - topOffset)
        scaleY = contentHeight / Self.canvasSize.height
        originY = topOffset
    }

    var waveformCenter: CGPoint {
        center(of: Self.waveformRect)
    }

    var waveformSize: CGSize {
        scaledSize(of: Self.waveformRect)
    }

    var micCenter: CGPoint {
        center(of: Self.micRect)
    }

    var micHitSize: CGSize {
        let size = scaledSize(of: Self.micRect)
        return CGSize(width: max(size.width, 118), height: max(size.height, 118))
    }

    var topLeftCenter: CGPoint {
        center(of: Self.leftButtonRect)
    }

    var topRightCenter: CGPoint {
        center(of: Self.rightButtonRect)
    }

    var topButtonSize: CGSize {
        let size = scaledSize(of: Self.leftButtonRect)
        return CGSize(width: max(size.width, 54), height: max(size.height, 54))
    }

    private func center(of rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.midX * scaleX,
            y: originY + rect.midY * scaleY
        )
    }

    private func scaledSize(of rect: CGRect) -> CGSize {
        CGSize(width: rect.width * scaleX, height: rect.height * scaleY)
    }
}

struct RecordingHUDView: View {
    @State private var isRecording = false
    @Namespace private var namespace

    var body: some View {
        ZStack {
            DoodlePalette.paperBg
                .ignoresSafeArea()
                .messyScribbleBackground(color: DoodlePalette.brutalPink, opacity: 0.06)

            VStack {
                Spacer(minLength: 0)

                DoodleActionBar(isRecording: $isRecording, namespace: namespace)
            }

            if isRecording {
                ExpandedRecordingHUD(isRecording: $isRecording, namespace: namespace)
                    .zIndex(10)
            }
        }
        .statusBarHidden(isRecording)
    }
}

#Preview("Recording HUD") {
    RecordingHUDView()
}

#Preview("Recording HUD Expanded") {
    @Previewable @State var isRecording = true
    @Previewable @Namespace var namespace

    ExpandedRecordingHUD(isRecording: $isRecording, namespace: namespace)
}
