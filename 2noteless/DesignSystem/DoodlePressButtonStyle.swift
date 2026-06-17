import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum BrutalHaptic {
    case light
    case medium
    case heavy

    @MainActor
    func impact() {
        #if canImport(UIKit)
        switch self {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        #endif
    }
}

struct BrutalButtonStyle: ButtonStyle {
    enum ShapeKind {
        case circle
        case roundedRectangle(cornerRadius: CGFloat)
    }

    let fillColor: Color
    let foregroundColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let shadowColor: Color
    let shadowOffset: CGSize
    let pressedOffset: CGSize
    let pressedScale: CGFloat
    let shape: ShapeKind
    let haptic: BrutalHaptic?

    init(
        fillColor: Color = .white,
        foregroundColor: Color = DoodlePalette.markerBlack,
        borderColor: Color = DoodlePalette.markerBlack,
        borderWidth: CGFloat = 3,
        shadowColor: Color = DoodlePalette.markerBlack,
        shadowOffset: CGSize = CGSize(width: 4, height: 4),
        pressedOffset: CGSize = CGSize(width: 4, height: 4),
        pressedScale: CGFloat = 0.95,
        shape: ShapeKind = .circle,
        haptic: BrutalHaptic? = nil
    ) {
        self.fillColor = fillColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.pressedOffset = pressedOffset
        self.pressedScale = pressedScale
        self.shape = shape
        self.haptic = haptic
    }

    func makeBody(configuration: Configuration) -> some View {
        BrutalButtonStyleBody(
            configuration: configuration,
            fillColor: fillColor,
            foregroundColor: foregroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            pressedOffset: pressedOffset,
            pressedScale: pressedScale,
            shape: shape,
            haptic: haptic
        )
    }
}

private struct BrutalButtonStyleBody: View {
    let configuration: ButtonStyle.Configuration
    let fillColor: Color
    let foregroundColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let shadowColor: Color
    let shadowOffset: CGSize
    let pressedOffset: CGSize
    let pressedScale: CGFloat
    let shape: BrutalButtonStyle.ShapeKind
    let haptic: BrutalHaptic?

    var body: some View {
        let pressed = configuration.isPressed

        configuration.label
            .font(.system(size: 21, weight: .black, design: .rounded))
            .foregroundStyle(foregroundColor)
            .background {
                BrutalButtonSurface(
                    fillColor: fillColor,
                    borderColor: borderColor,
                    borderWidth: borderWidth,
                    shape: shape
                )
                .shadow(
                    color: shadowColor,
                    radius: 0,
                    x: pressed ? 0 : shadowOffset.width,
                    y: pressed ? 0 : shadowOffset.height
                )
            }
            .offset(x: pressed ? pressedOffset.width : 0, y: pressed ? pressedOffset.height : 0)
            .scaleEffect(pressed ? pressedScale : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressed)
            .onChange(of: pressed) { _, isPressed in
                if isPressed {
                    haptic?.impact()
                }
            }
    }
}

struct BrutalMicButtonStyle: ButtonStyle {
    let shadowColor: Color
    let shadowOffset: CGSize
    let pressedOffset: CGSize
    let haptic: BrutalHaptic?

    init(
        shadowColor: Color = DoodlePalette.markerBlack,
        shadowOffset: CGSize = CGSize(width: 6, height: 6),
        pressedOffset: CGSize = CGSize(width: 6, height: 6),
        haptic: BrutalHaptic? = .heavy
    ) {
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.pressedOffset = pressedOffset
        self.haptic = haptic
    }

    func makeBody(configuration: Configuration) -> some View {
        BrutalMicButtonStyleBody(
            configuration: configuration,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            pressedOffset: pressedOffset,
            haptic: haptic
        )
    }
}

private struct BrutalMicButtonStyleBody: View {
    let configuration: ButtonStyle.Configuration
    let shadowColor: Color
    let shadowOffset: CGSize
    let pressedOffset: CGSize
    let haptic: BrutalHaptic?

    var body: some View {
        let pressed = configuration.isPressed

        configuration.label
            .shadow(
                color: shadowColor,
                radius: 0,
                x: pressed ? 0 : shadowOffset.width,
                y: pressed ? 0 : shadowOffset.height
            )
            .offset(x: pressed ? pressedOffset.width : 0, y: pressed ? pressedOffset.height : 0)
            .scaleEffect(pressed ? 0.85 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressed)
            .onChange(of: pressed) { _, isPressed in
                if isPressed {
                    haptic?.impact()
                }
            }
    }
}

private struct BrutalButtonSurface: View {
    let fillColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let shape: BrutalButtonStyle.ShapeKind

    var body: some View {
        Group {
            switch shape {
            case .circle:
                Circle()
                    .fill(fillColor)
                    .overlay {
                        Circle()
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
            case .roundedRectangle(let cornerRadius):
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fillColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
            }
        }
    }
}

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
