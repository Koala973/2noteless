import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct ExpandedRecordingHUD: View {
    @Binding var isRecording: Bool
    let namespace: Namespace.ID
    let waveformSamples: [CGFloat]

    @State private var auraPulse = false

    init(
        isRecording: Binding<Bool>,
        namespace: Namespace.ID,
        waveformSamples: [CGFloat] = ExpandedRecordingHUD.defaultSamples
    ) {
        self._isRecording = isRecording
        self.namespace = namespace
        self.waveformSamples = waveformSamples
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: close)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    panel(height: panelHeight(for: proxy.size.height))
                        .padding(.horizontal, 20)
                        .padding(.bottom, max(18, proxy.safeAreaInsets.bottom + 8))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .transition(.opacity)
        .onAppear(perform: startAura)
        .onDisappear {
            auraPulse = false
        }
    }

    private func panel(height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(DoodlePalette.markerBlack, lineWidth: 4)
                }
                .shadow(
                    color: DoodlePalette.bubblegumPink.opacity(auraPulse ? 0.52 : 0.22),
                    radius: 0,
                    x: -5,
                    y: -5
                )
                .shadow(color: DoodlePalette.markerBlack, radius: 0, x: 5, y: 5)
                .matchedGeometryEffect(id: "recordingHUD", in: namespace)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(DoodlePalette.bubblegumPink.opacity(auraPulse ? 0.34 : 0.14))
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 16) {
                Text("DUMPING BRAIN...")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(DoodlePalette.markerBlack)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
                    let phase = CGFloat(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60))
                    DoodleWaveformView(samples: waveformSamples, phase: phase)
                }
                .frame(height: 142)
                .padding(.vertical, 2)

                Spacer(minLength: 0)

                HStack {
                    Spacer(minLength: 0)

                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 58, height: 54)
                            .background {
                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                    .fill(DoodlePalette.markerBlack)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                                            .stroke(DoodlePalette.markerBlack, lineWidth: 3)
                                    }
                                    .shadow(color: DoodlePalette.markerBlack, radius: 0, x: 4, y: 4)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Stop recording")
                    .accessibilityIdentifier("recordingHUD.stopButton")

                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 26)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: 430)
        .frame(height: height)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Recording brain dump panel")
    }

    private func close() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        withAnimation(.spring(response: 0.4, dampingFraction: 0.68, blendDuration: 0)) {
            isRecording = false
        }
    }

    private func startAura() {
        auraPulse = false
        withAnimation(.easeInOut(duration: 0.64).repeatForever(autoreverses: true)) {
            auraPulse = true
        }
    }

    private func panelHeight(for containerHeight: CGFloat) -> CGFloat {
        min(390, max(318, containerHeight * 0.40))
    }

    private static let defaultSamples: [CGFloat] = [
        -0.72, 0.54, -0.36, 0.78, -0.62, 0.44, 0.86, -0.58,
        0.35, -0.82, 0.66, -0.24, 0.74, -0.68, 0.52, -0.46
    ]
}

struct RecordingHUDView: View {
    @State private var isRecording = false
    @Namespace private var namespace

    var body: some View {
        ZStack {
            DoodlePalette.paperBg
                .ignoresSafeArea()
                .messyScribbleBackground(color: DoodlePalette.bubblegumPink, opacity: 0.06)

            VStack {
                Spacer(minLength: 0)

                DoodleActionBar(isRecording: $isRecording, namespace: namespace)
            }

            if isRecording {
                ExpandedRecordingHUD(isRecording: $isRecording, namespace: namespace)
                    .zIndex(10)
            }
        }
    }
}

#Preview("Recording HUD") {
    RecordingHUDView()
}

#Preview("Recording HUD Expanded") {
    @Previewable @State var isRecording = true
    @Previewable @Namespace var namespace

    ZStack {
        DoodlePalette.paperBg.ignoresSafeArea()
        DoodleActionBar(isRecording: $isRecording, namespace: namespace)
        ExpandedRecordingHUD(isRecording: $isRecording, namespace: namespace)
    }
}
