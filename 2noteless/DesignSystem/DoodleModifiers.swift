import SwiftUI

struct DoodleBorderModifier<S: InsettableShape>: ViewModifier {
    let shape: S
    let lineWidth: CGFloat
    let color: Color

    init(
        shape: S,
        lineWidth: CGFloat = 3,
        color: Color = DoodlePalette.markerBlack
    ) {
        self.shape = shape
        self.lineWidth = lineWidth
        self.color = color
    }

    func body(content: Content) -> some View {
        content.overlay {
            shape.stroke(color, lineWidth: lineWidth)
        }
    }
}

struct BrutalShadowModifier: ViewModifier {
    let color: Color
    let x: CGFloat
    let y: CGFloat

    init(
        color: Color = DoodlePalette.markerBlack,
        x: CGFloat = 5,
        y: CGFloat = 5
    ) {
        self.color = color
        self.x = x
        self.y = y
    }

    func body(content: Content) -> some View {
        content.shadow(color: color, radius: 0, x: x, y: y)
    }
}

struct MessyScribbleBackground: ViewModifier {
    let color: Color
    let opacity: Double

    init(color: Color = DoodlePalette.bubblegumPink, opacity: Double = 0.18) {
        self.color = color
        self.opacity = opacity
    }

    func body(content: Content) -> some View {
        content.background {
            Canvas { context, size in
                for index in 0..<12 {
                    let progress = CGFloat(index) / 12
                    let width = size.width * (0.28 + 0.15 * sin(progress * .pi * 4))
                    let height = size.height * (0.18 + 0.10 * cos(progress * .pi * 5))
                    let x = size.width * (0.08 + 0.78 * progress)
                    let y = size.height * (0.18 + 0.62 * abs(sin(progress * .pi * 2)))
                    let rect = CGRect(x: x - width / 2, y: y - height / 2, width: width, height: height)
                    var path = Path(ellipseIn: rect)
                    let angle = Angle.degrees(Double(index * 19 - 80))
                    path = path.applying(CGAffineTransform(translationX: -rect.midX, y: -rect.midY))
                    path = path.applying(CGAffineTransform(rotationAngle: CGFloat(angle.radians)))
                    path = path.applying(CGAffineTransform(translationX: rect.midX, y: rect.midY))
                    context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: 2.4)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

extension View {
    func doodleBorder<S: InsettableShape>(
        _ shape: S,
        lineWidth: CGFloat = 3,
        color: Color = DoodlePalette.markerBlack
    ) -> some View {
        modifier(DoodleBorderModifier(shape: shape, lineWidth: lineWidth, color: color))
    }

    func brutalShadow(
        color: Color = DoodlePalette.markerBlack,
        x: CGFloat = 5,
        y: CGFloat = 5
    ) -> some View {
        modifier(BrutalShadowModifier(color: color, x: x, y: y))
    }

    func messyScribbleBackground(
        color: Color = DoodlePalette.bubblegumPink,
        opacity: Double = 0.18
    ) -> some View {
        modifier(MessyScribbleBackground(color: color, opacity: opacity))
    }
}
