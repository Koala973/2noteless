import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct RecordingHUDView: View {
    private let externalRecording: Binding<Bool>?
    private let collapsedBottomPadding: CGFloat
    private let expandedBottomPadding: CGFloat
    private let waveformSamples: [CGFloat]

    @Namespace private var animation
    @State private var localRecording = false
    @State private var auraPulse = false

    init(
        isRecording: Binding<Bool>? = nil,
        collapsedBottomPadding: CGFloat = 18,
        expandedBottomPadding: CGFloat = 16,
        waveformSamples: [CGFloat] = RecordingHUDView.defaultSamples
    ) {
        self.externalRecording = isRecording
        self.collapsedBottomPadding = collapsedBottomPadding
        self.expandedBottomPadding = expandedBottomPadding
        self.waveformSamples = waveformSamples
    }

    var body: some View {
        GeometryReader { proxy in
            let recording = recordingBinding

            ZStack(alignment: .bottom) {
                if recording.wrappedValue {
                    Color.black.opacity(0.22)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            setRecording(false)
                        }
                        .transition(.opacity)
                        .zIndex(1)

                    expandedPanel(height: panelHeight(for: proxy.size.height))
                        .padding(.horizontal, 20)
                        .padding(.bottom, max(expandedBottomPadding, proxy.safeAreaInsets.bottom + expandedBottomPadding))
                        .transition(.opacity)
                        .zIndex(2)
                } else {
                    collapsedMicButton
                        .padding(.bottom, max(collapsedBottomPadding, proxy.safeAreaInsets.bottom + collapsedBottomPadding))
                        .transition(.opacity)
                        .zIndex(3)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
            .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0), value: recording.wrappedValue)
        }
    }

    private var recordingBinding: Binding<Bool> {
        externalRecording ?? Binding(
            get: { localRecording },
            set: { localRecording = $0 }
        )
    }

    private var collapsedMicButton: some View {
        Button {
            setRecording(true)
        } label: {
            ZStack {
                Circle()
                    .fill(DoodlePalette.bubblegumPink)
                    .overlay {
                        Circle()
                            .stroke(DoodlePalette.markerBlack, lineWidth: 4)
                    }
                    .shadow(color: DoodlePalette.markerBlack, radius: 0, x: 4, y: 4)
                    .matchedGeometryEffect(id: "hudBackground", in: animation)

                Image(systemName: "mic.fill")
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 25, weight: .black))
                    .foregroundStyle(.white)
            }
            .frame(width: 56, height: 56)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .tint(.white)
        .accessibilityLabel("Start recording")
        .accessibilityIdentifier("recordingHUD.startButton")
    }

    private func expandedPanel(height: CGFloat) -> some View {
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
                .matchedGeometryEffect(id: "hudBackground", in: animation)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
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

                    Button {
                        setRecording(false)
                    } label: {
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
        .onAppear(perform: startAura)
        .onDisappear {
            auraPulse = false
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Recording brain dump panel")
    }

    private func panelHeight(for containerHeight: CGFloat) -> CGFloat {
        min(390, max(318, containerHeight * 0.40))
    }

    private func setRecording(_ recording: Bool) {
        impact(recording ? .heavy : .medium)
        withAnimation(.spring(response: 0.4, dampingFraction: recording ? 0.6 : 0.68, blendDuration: 0)) {
            recordingBinding.wrappedValue = recording
        }
    }

    private func startAura() {
        auraPulse = false
        withAnimation(.easeInOut(duration: 0.64).repeatForever(autoreverses: true)) {
            auraPulse = true
        }
    }

    private func impact(_ style: ImpactStyle) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: style.feedbackStyle).impactOccurred()
        #endif
    }

    private static let defaultSamples: [CGFloat] = [
        -0.72, 0.54, -0.36, 0.78, -0.62, 0.44, 0.86, -0.58,
        0.35, -0.82, 0.66, -0.24, 0.74, -0.68, 0.52, -0.46
    ]
}

private enum ImpactStyle {
    case heavy
    case medium

    #if canImport(UIKit)
    var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .heavy:
            return .heavy
        case .medium:
            return .medium
        }
    }
    #endif
}

#Preview("Recording HUD") {
    ZStack {
        DoodlePalette.paperBg
            .ignoresSafeArea()
            .messyScribbleBackground(color: DoodlePalette.bubblegumPink, opacity: 0.06)

        RecordingHUDView()
    }
}

#Preview("Recording HUD Bound") {
    @Previewable @State var isRecording = true

    ZStack {
        DoodlePalette.paperBg.ignoresSafeArea()
        RecordingHUDView(isRecording: $isRecording)
    }
}
