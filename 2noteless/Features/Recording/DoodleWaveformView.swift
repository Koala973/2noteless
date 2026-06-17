import SwiftUI

struct DoodleWaveformView: View {
    let samples: [CGFloat]
    let phase: CGFloat

    private var normalizedSamples: [CGFloat] {
        let fallback: [CGFloat] = [-0.18, 0.32, -0.46, 0.14, 0.58, -0.26, 0.42, -0.34]
        return (samples.isEmpty ? fallback : samples).map { min(max($0, -1), 1) }
    }

    var body: some View {
        Canvas { context, size in
            guard size.width > 0, size.height > 0 else { return }

            let values = normalizedSamples
            let pointCount = max(80, values.count * 5)
            let centerY = size.height / 2
            let amplitude = size.height * 0.42

            for layer in 0..<2 {
                var path = Path()
                let layerPhase = phase + CGFloat(layer) * 0.48
                let layerOffset = CGFloat(layer) * 4

                for index in 0...pointCount {
                    let progress = CGFloat(index) / CGFloat(pointCount)
                    let x = progress * size.width
                    let sample = values[index % values.count]
                    let jitter = sin(CGFloat(index) * 1.73 + layerPhase * 2.4) * 0.18
                    let scratch = cos(CGFloat(index) * 4.1 + layerPhase * 1.1) * 0.10
                    let loop = sin(progress * .pi * 10 + layerPhase * 1.7) * 0.22
                    let y = centerY - ((sample * 0.72) + jitter + scratch + loop) * amplitude + layerOffset

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        let previousProgress = CGFloat(index - 1) / CGFloat(pointCount)
                        let previousX = previousProgress * size.width
                        let controlX = (previousX + x) / 2
                        let controlY = y + sin(CGFloat(index) * 2.2 + layerPhase) * 11
                        path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: controlX, y: controlY))
                    }
                }

                context.stroke(
                    path,
                    with: .color(DoodlePalette.markerBlack.opacity(layer == 0 ? 1 : 0.62)),
                    style: StrokeStyle(
                        lineWidth: layer == 0 ? 3.4 : 1.8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }
        }
        .frame(height: 150)
        .accessibilityLabel("Animated doodle waveform")
    }
}

#Preview {
    ZStack {
        DoodlePalette.paperBg.ignoresSafeArea()
        DoodleWaveformView(
            samples: [-0.2, 0.35, -0.5, 0.22, 0.7, -0.4, 0.48, -0.12, 0.58, -0.66],
            phase: 1.2
        )
        .padding(24)
    }
}
