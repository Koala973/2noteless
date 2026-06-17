import SwiftUI

struct DoodlePressButtonStyle: ButtonStyle {
    enum ShapeKind {
        case circle
        case roundedRectangle(cornerRadius: CGFloat)
    }

    let fillColor: Color
    let foregroundColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let shadowOffset: CGFloat
    let shape: ShapeKind

    init(
        fillColor: Color = .white,
        foregroundColor: Color = DoodlePalette.markerBlack,
        borderColor: Color = DoodlePalette.markerBlack,
        borderWidth: CGFloat = 3,
        shadowOffset: CGFloat = 3,
        shape: ShapeKind = .circle
    ) {
        self.fillColor = fillColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowOffset = shadowOffset
        self.shape = shape
    }

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        configuration.label
            .font(.system(size: 21, weight: .black, design: .rounded))
            .foregroundStyle(foregroundColor)
            .background {
                DoodleButtonChrome(
                    fillColor: fillColor,
                    borderColor: borderColor,
                    borderWidth: borderWidth,
                    shadowOffset: pressed ? 0 : shadowOffset,
                    shape: shape
                )
            }
            .offset(x: pressed ? 2 : 0, y: pressed ? 2 : 0)
            .scaleEffect(pressed ? 0.98 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.62), value: pressed)
    }
}

private struct DoodleButtonChrome: View {
    let fillColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let shadowOffset: CGFloat
    let shape: DoodlePressButtonStyle.ShapeKind

    var body: some View {
        Group {
            switch shape {
            case .circle:
                Circle()
                    .fill(fillColor)
                    .doodleBorder(Circle(), lineWidth: borderWidth, color: borderColor)
                    .brutalShadow(color: borderColor, x: shadowOffset, y: shadowOffset)
            case .roundedRectangle(let cornerRadius):
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fillColor)
                    .doodleBorder(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
                        lineWidth: borderWidth,
                        color: borderColor
                    )
                    .brutalShadow(color: borderColor, x: shadowOffset, y: shadowOffset)
            }
        }
    }
}
