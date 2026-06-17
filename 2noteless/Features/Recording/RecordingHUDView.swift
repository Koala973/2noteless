import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct ExpandedRecordingHUD: View {
    @Binding var isRecording: Bool
    let namespace: Namespace.ID

    @State private var isAnimating = false
    @State private var waveformScaleY: CGFloat = 1
    @State private var waveformOffsetY: CGFloat = 0
    @State private var waveformRotation: Double = 0

    private let waveformTimer = Timer.publish(every: 0.11, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                DoodlePalette.paperBg
                    .ignoresSafeArea()
                    .messyScribbleBackground(color: DoodlePalette.bubblegumPink, opacity: 0.05)

                RecordingPaperTexture()
                    .ignoresSafeArea()

                recordingAssets(in: proxy)

                VStack(alignment: .leading, spacing: 0) {
                    RecordingHeroTitle()
                        .padding(.top, topContentInset(for: proxy))
                        .padding(.leading, 24)
                        .padding(.trailing, 18)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                VStack(spacing: 8) {
                    Spacer(minLength: 0)

                    giantMicButton

                    VStack(spacing: 2) {
                        Text("Tap to stop & capture")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(DoodlePalette.markerBlack)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)

                        Capsule()
                            .fill(DoodlePalette.bubblegumPink)
                            .frame(width: 154, height: 3)
                            .rotationEffect(.degrees(-1.4))
                    }
                    .padding(.bottom, max(22, proxy.safeAreaInsets.bottom + 10))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea()
        .transition(.opacity)
        .onAppear(perform: startAnimations)
        .onDisappear(perform: stopAnimations)
        .onReceive(waveformTimer) { _ in
            guard isAnimating else { return }
            withAnimation(.spring(response: 0.1, dampingFraction: 0.3, blendDuration: 0)) {
                waveformScaleY = CGFloat.random(in: 0.78...1.5)
                waveformOffsetY = CGFloat.random(in: -14...14)
                waveformRotation = Double.random(in: -1.8...1.8)
            }
        }
    }

    private func recordingAssets(in proxy: GeometryProxy) -> some View {
        ZStack {
            Image("giant_pink_aura")
                .resizable()
                .scaledToFit()
                .frame(width: proxy.size.width * 1.72)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .rotationEffect(.degrees(isAnimating ? 5 : -5))
                .opacity(0.96)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.52)

            Image("chaotic_waveform")
                .resizable()
                .scaledToFit()
                .frame(width: proxy.size.width * 1.52)
                .scaleEffect(x: 1.03, y: waveformScaleY, anchor: .center)
                .rotationEffect(.degrees(waveformRotation))
                .offset(y: waveformOffsetY)
                .animation(.spring(response: 0.1, dampingFraction: 0.3, blendDuration: 0), value: waveformScaleY)
                .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.53)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var giantMicButton: some View {
        Button(action: close) {
            Image("brutal_mic_button")
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .matchedGeometryEffect(id: "micButton", in: namespace)
                .scaleEffect(isAnimating ? 1.035 : 0.965)
                .animation(.spring(response: 0.34, dampingFraction: 0.48, blendDuration: 0).repeatForever(autoreverses: true), value: isAnimating)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Stop recording")
        .accessibilityIdentifier("recordingHUD.stopButton")
    }

    private func close() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        withAnimation(.spring(response: 0.4, dampingFraction: 0.68, blendDuration: 0)) {
            isRecording = false
        }
    }

    private func startAnimations() {
        waveformScaleY = 1
        waveformOffsetY = 0
        waveformRotation = 0
        withAnimation(.spring(response: 0.38, dampingFraction: 0.58, blendDuration: 0)) {
            isAnimating = true
        }
    }

    private func stopAnimations() {
        isAnimating = false
        waveformScaleY = 1
        waveformOffsetY = 0
        waveformRotation = 0
    }

    private func topContentInset(for proxy: GeometryProxy) -> CGFloat {
        max(70, proxy.safeAreaInsets.top + 24)
    }
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

private struct RecordingHeroTitle: View {
    var body: some View {
        VStack(alignment: .leading, spacing: -8) {
            Text("DUMPING")
            Text("BRAIN...")
        }
        .font(.system(size: 56, weight: .black, design: .rounded))
        .foregroundStyle(DoodlePalette.markerBlack)
        .multilineTextAlignment(.leading)
        .lineLimit(1)
        .minimumScaleFactor(0.68)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel("DUMPING BRAIN...")
    }
}

private struct RecordingPaperTexture: View {
    var body: some View {
        Canvas { context, size in
            for index in 0..<120 {
                let progress = CGFloat(index)
                let x = abs(sin(progress * 12.9898) * 43758.5453).truncatingRemainder(dividingBy: 1) * size.width
                let y = abs(cos(progress * 78.233) * 12937.1371).truncatingRemainder(dividingBy: 1) * size.height
                let radius = CGFloat(index % 3 + 1) * 0.6
                let color = index % 4 == 0 ? DoodlePalette.bubblegumPink.opacity(0.18) : DoodlePalette.markerBlack.opacity(0.035)
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)), with: .color(color))
            }
        }
        .allowsHitTesting(false)
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
