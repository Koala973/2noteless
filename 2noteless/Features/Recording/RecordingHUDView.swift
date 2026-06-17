import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct ExpandedRecordingHUD: View {
    @Binding var isRecording: Bool
    let namespace: Namespace.ID

    @State private var auraPulse = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                DoodlePalette.paperBg
                    .ignoresSafeArea()
                    .messyScribbleBackground(color: DoodlePalette.bubblegumPink, opacity: 0.07)

                RecordingPaperTexture()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: topContentInset(for: proxy))

                    MrMessyPeek()
                        .frame(width: 126, height: 54)
                        .padding(.bottom, 4)

                    RecordingHeroTitle()
                        .padding(.horizontal, 20)

                    PinkDoodleUnderline()
                        .frame(width: min(250, proxy.size.width * 0.58), height: 14)
                        .padding(.top, 4)

                    Spacer(minLength: 16)

                    ZStack {
                        GiantRecordingAura(isPulsing: auraPulse)
                            .frame(width: proxy.size.width * 1.28, height: waveformHeight(for: proxy.size.height) * 1.06)

                        PinkBurstMarks()
                            .frame(width: proxy.size.width * 0.92, height: waveformHeight(for: proxy.size.height))

                        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
                            let phase = CGFloat(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60))
                            ImmersiveDoodleWaveformView(phase: phase)
                        }
                    }
                    .frame(height: waveformHeight(for: proxy.size.height))
                    .padding(.horizontal, -18)

                    Spacer(minLength: 18)

                    giantMicButton
                        .padding(.bottom, 12)

                    VStack(spacing: 2) {
                        Text("Tap to stop & capture")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(DoodlePalette.markerBlack)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)

                        PinkDoodleUnderline()
                            .frame(width: 160, height: 9)
                    }
                    .padding(.bottom, max(22, proxy.safeAreaInsets.bottom + 10))
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .ignoresSafeArea()
        .transition(.opacity)
        .onAppear(perform: startAura)
        .onDisappear {
            auraPulse = false
        }
    }

    private var giantMicButton: some View {
        Button(action: close) {
            ZStack {
                Circle()
                    .fill(DoodlePalette.bubblegumPink)
                    .shadow(color: DoodlePalette.bubblegumPink.opacity(0.34), radius: 0, x: 0, y: 9)
                    .matchedGeometryEffect(id: "micButton", in: namespace)

                MicButtonScribble()
                    .padding(3)

                Circle()
                    .stroke(DoodlePalette.markerBlack, lineWidth: 4)

                Image(systemName: "mic.fill")
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(DoodlePalette.markerBlack)
                    .shadow(color: .white.opacity(0.78), radius: 0, x: 2, y: 2)
            }
            .frame(width: 104, height: 104)
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

    private func startAura() {
        auraPulse = false
        withAnimation(.easeInOut(duration: 0.74).repeatForever(autoreverses: true)) {
            auraPulse = true
        }
    }

    private func waveformHeight(for screenHeight: CGFloat) -> CGFloat {
        min(360, max(270, screenHeight * 0.36))
    }

    private func topContentInset(for proxy: GeometryProxy) -> CGFloat {
        max(64, proxy.safeAreaInsets.top + 18)
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
        VStack(spacing: -2) {
            Text("DUMPING")
                .rotationEffect(.degrees(-1.4))

            Text("BRAIN...")
                .rotationEffect(.degrees(1.1))
                .padding(.leading, 18)
        }
        .font(.system(size: 48, weight: .heavy, design: .rounded))
        .foregroundStyle(DoodlePalette.markerBlack)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .minimumScaleFactor(0.74)
        .frame(maxWidth: .infinity)
        .accessibilityLabel("DUMPING BRAIN...")
    }
}

private struct GiantRecordingAura: View {
    let isPulsing: Bool

    var body: some View {
        Circle()
            .fill(DoodlePalette.bubblegumPink.opacity(isPulsing ? 0.44 : 0.28))
            .blur(radius: 60)
            .scaleEffect(isPulsing ? 1.08 : 0.94)
            .allowsHitTesting(false)
    }
}

private struct ImmersiveDoodleWaveformView: View {
    let phase: CGFloat

    var body: some View {
        Canvas { context, size in
            guard size.width > 0, size.height > 0 else { return }

            let extendedWidth = size.width + 96
            let startX: CGFloat = -48
            let centerY = size.height * 0.52
            let pointCount = 180

            for layer in 0..<7 {
                var path = Path()
                let layerPhase = phase * (0.92 + CGFloat(layer) * 0.06) + CGFloat(layer) * 0.77
                let lineWeight: CGFloat = layer < 3 ? 3.7 : 2.4

                for index in 0...pointCount {
                    let progress = CGFloat(index) / CGFloat(pointCount)
                    let xNoise = sin(CGFloat(index) * 1.91 + layerPhase) * CGFloat(layer + 1)
                    let x = startX + progress * extendedWidth + xNoise
                    let centerEnvelope = pow(max(0, sin(progress * CGFloat.pi)), 1.7)
                    let amplitude = size.height * (0.07 + 0.58 * centerEnvelope)
                    let loopA = sin(progress * CGFloat.pi * CGFloat(12 + layer * 2) + layerPhase * 1.8)
                    let loopB = cos(progress * CGFloat.pi * CGFloat(27 + layer) - layerPhase * 1.3)
                    let scratch = sin(CGFloat(index) * 2.8 + layerPhase * 2.2) * 0.22
                    let y = centerY + (loopA * 0.78 + loopB * 0.36 + scratch) * amplitude

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        let previousProgress = CGFloat(index - 1) / CGFloat(pointCount)
                        let controlX = startX + (previousProgress + progress) * extendedWidth / 2
                        let controlY = centerY + sin(CGFloat(index) * 3.6 + layerPhase) * amplitude * 0.92
                        path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: controlX, y: controlY))
                    }
                }

                context.stroke(
                    path,
                    with: .color(DoodlePalette.markerBlack.opacity(layer < 4 ? 0.96 : 0.58)),
                    style: StrokeStyle(lineWidth: lineWeight, lineCap: .round, lineJoin: .round)
                )
            }

            var centerScratch = Path()
            centerScratch.move(to: CGPoint(x: startX, y: centerY))
            for index in 0...90 {
                let progress = CGFloat(index) / 90
                let x = startX + progress * extendedWidth
                let y = centerY + sin(progress * CGFloat.pi * 90 + phase) * 8
                centerScratch.addLine(to: CGPoint(x: x, y: y))
            }
            context.stroke(
                centerScratch,
                with: .color(DoodlePalette.markerBlack.opacity(0.72)),
                style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
            )
        }
        .accessibilityLabel("Chaotic recording waveform")
    }
}

private struct MicButtonScribble: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            for index in 0..<16 {
                let progress = CGFloat(index) / 16
                let width = size.width * (0.72 + 0.16 * sin(progress * CGFloat.pi * 7))
                let height = size.height * (0.58 + 0.15 * cos(progress * CGFloat.pi * 6))
                let rect = CGRect(
                    x: center.x - width / 2,
                    y: center.y - height / 2,
                    width: width,
                    height: height
                )
                var path = Path(ellipseIn: rect)
                path = path.applying(CGAffineTransform(translationX: -center.x, y: -center.y))
                path = path.applying(CGAffineTransform(rotationAngle: progress * CGFloat.pi * 2.8))
                path = path.applying(CGAffineTransform(translationX: center.x, y: center.y))

                context.stroke(
                    path,
                    with: .color((index % 5 == 0 ? DoodlePalette.markerBlack : Color.white).opacity(index % 5 == 0 ? 0.84 : 0.38)),
                    lineWidth: index % 5 == 0 ? 2.4 : 1.4
                )
            }
        }
        .allowsHitTesting(false)
    }
}

private struct PinkBurstMarks: View {
    var body: some View {
        Canvas { context, size in
            let bursts: [(origin: CGPoint, angles: [CGFloat])] = [
                (CGPoint(x: size.width * 0.08, y: size.height * 0.34), [-0.70, -0.34, 0.05]),
                (CGPoint(x: size.width * 0.92, y: size.height * 0.34), [CGFloat.pi + 0.70, CGFloat.pi + 0.34, CGFloat.pi - 0.05]),
                (CGPoint(x: size.width * 0.30, y: size.height * 0.88), [-2.6, -2.25]),
                (CGPoint(x: size.width * 0.70, y: size.height * 0.88), [-0.88, -0.52])
            ]

            for burst in bursts {
                for (index, angle) in burst.angles.enumerated() {
                    var path = Path()
                    let length = CGFloat(28 + index * 8)
                    path.move(to: burst.origin)
                    path.addLine(to: CGPoint(x: burst.origin.x + cos(angle) * length, y: burst.origin.y + sin(angle) * length))
                    context.stroke(
                        path,
                        with: .color(DoodlePalette.bubblegumPink.opacity(0.88)),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct PinkDoodleUnderline: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 2, y: size.height * 0.58))
            path.addQuadCurve(
                to: CGPoint(x: size.width - 2, y: size.height * 0.40),
                control: CGPoint(x: size.width * 0.48, y: size.height * 0.78)
            )
            context.stroke(
                path,
                with: .color(DoodlePalette.bubblegumPink),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

private struct MrMessyPeek: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Canvas { context, size in
                for index in 0..<13 {
                    let progress = CGFloat(index) / 13
                    let width = size.width * (0.34 + 0.12 * sin(progress * CGFloat.pi * 5))
                    let height = size.height * (0.48 + 0.12 * cos(progress * CGFloat.pi * 4))
                    let rect = CGRect(
                        x: size.width * (0.25 + progress * 0.48) - width / 2,
                        y: size.height * 0.44 - height / 2,
                        width: width,
                        height: height
                    )
                    context.stroke(Path(ellipseIn: rect), with: .color(DoodlePalette.bubblegumPink), lineWidth: 3)
                }
            }

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                HStack(spacing: 10) {
                    Circle().fill(.white).frame(width: 10, height: 10).overlay(Circle().fill(DoodlePalette.markerBlack).frame(width: 4, height: 4))
                    Circle().fill(.white).frame(width: 10, height: 10).overlay(Circle().fill(DoodlePalette.markerBlack).frame(width: 4, height: 4))
                }
                Spacer()
                    .frame(height: 22)
            }

            Path { path in
                path.move(to: CGPoint(x: 18, y: 48))
                path.addLine(to: CGPoint(x: 108, y: 42))
            }
            .stroke(DoodlePalette.markerBlack, lineWidth: 2)
        }
        .allowsHitTesting(false)
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
