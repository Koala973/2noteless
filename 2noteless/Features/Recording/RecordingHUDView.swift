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
                    .frame(width: layout.waveformSize.width * 1.12, height: layout.waveformSize.height)
                    .scaleEffect(x: 1, y: waveformScaleY, anchor: .center)
                    .offset(x: waveformNudgeX)
                    .position(layout.waveformCenter)
                    .mask(RecordingWaveformEdgeFade())
                    .animation(.spring(response: 0.15, dampingFraction: 0.4, blendDuration: 0), value: waveformScaleY)
                    .animation(.spring(response: 0.15, dampingFraction: 0.4, blendDuration: 0), value: waveformNudgeX)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                micButton(layout: layout)

                topControls(topInset: topControlTopInset(for: proxy))
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

    private func micButton(layout: RecordingHUDFigmaLayout) -> some View {
        Button(action: close) {
            Image("brutal_mic_button")
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: layout.micButtonDiameter, height: layout.micButtonDiameter)
                .matchedGeometryEffect(id: "micButton", in: namespace)
                .contentShape(Circle())
        }
        .buttonStyle(RecordingHUDMicArtworkButtonStyle())
        .position(layout.micCenter)
        .accessibilityLabel("Stop recording")
        .accessibilityIdentifier("recordingHUD.stopButton")
    }

    private func topControls(topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: close) {
                    RecordingMenuGlyph()
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(
                    BrutalButtonStyle(
                        fillColor: .white,
                        foregroundColor: DoodlePalette.markerBlack,
                        borderWidth: 2,
                        shadowOffset: CGSize(width: 3, height: 3),
                        pressedOffset: CGSize(width: 3, height: 3),
                        pressedScale: 0.94,
                        shape: .circle,
                        haptic: .light
                    )
                )
                .accessibilityLabel("Back")
                .accessibilityIdentifier("recordingHUD.backButton")

                Spacer(minLength: 0)

                Button(action: moreFeedback) {
                    RecordingMoreGlyph()
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(
                    BrutalButtonStyle(
                        fillColor: .white,
                        foregroundColor: DoodlePalette.markerBlack,
                        borderWidth: 2,
                        shadowOffset: CGSize(width: 3, height: 3),
                        pressedOffset: CGSize(width: 3, height: 3),
                        pressedScale: 0.94,
                        shape: .circle,
                        haptic: .medium
                    )
                )
                .accessibilityLabel("More actions")
                .accessibilityIdentifier("recordingHUD.moreButton")
            }
            .padding(.horizontal, 20)
            .padding(.top, topInset)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func topControlTopInset(for proxy: GeometryProxy) -> CGFloat {
        max(proxy.safeAreaInsets.top + 8, proxy.size.height > 860 ? 68 : 50)
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

private struct RecordingHUDFigmaLayout {
    private static let canvasSize = CGSize(width: 786, height: 1418)
    private static let waveformRect = CGRect(x: -13, y: 398, width: 815, height: 528)
    private static let micRect = CGRect(x: 228, y: 932, width: 330, height: 330)

    private let scaleX: CGFloat
    private let scaleY: CGFloat
    private let originY: CGFloat
    private let viewWidth: CGFloat
    let contentHeight: CGFloat

    static func topOffset(for proxy: GeometryProxy) -> CGFloat {
        proxy.safeAreaInsets.top > 55 ? 34 : 0
    }

    init(proxy: GeometryProxy, topOffset: CGFloat) {
        let viewSize = proxy.size
        viewWidth = viewSize.width
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

    var micButtonDiameter: CGFloat {
        let size = scaledSize(of: Self.micRect)
        return min(max(size.width, size.height), viewWidth * 0.5)
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

private struct RecordingWaveformEdgeFade: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.12),
                .init(color: .black, location: 0.88),
                .init(color: .clear, location: 1)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

private struct RecordingMenuGlyph: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Capsule()
                .frame(width: 18, height: 3)
                .offset(x: 4)
            Capsule()
                .frame(width: 22, height: 3)
            Capsule()
                .frame(width: 13, height: 3)
                .offset(x: 2)
        }
        .foregroundStyle(DoodlePalette.markerBlack)
    }
}

private struct RecordingMoreGlyph: View {
    var body: some View {
        HStack(spacing: 4) {
            Circle().frame(width: 6, height: 6)
            Circle().frame(width: 6, height: 6)
            Circle().frame(width: 6, height: 6)
        }
        .foregroundStyle(DoodlePalette.markerBlack)
    }
}

private struct RecordingHUDMicArtworkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.58), value: configuration.isPressed)
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
