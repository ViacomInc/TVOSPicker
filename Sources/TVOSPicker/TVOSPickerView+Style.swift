//  Copyright © 2023 Paramount. All rights reserved.

import UIKit

public struct TVOSPickerViewStyle: Equatable {
    public var componentSpacing: CGFloat

    public struct Backgrounds: Equatable {
        public var selectedCellBackgroundColor: UIColor
        public var focusedCellBackgroundColor: UIColor

        public init(selectedCellBackgroundColor: UIColor, focusedCellBackgroundColor: UIColor) {
            self.selectedCellBackgroundColor = selectedCellBackgroundColor
            self.focusedCellBackgroundColor = focusedCellBackgroundColor
        }
    }
    public var backgrounds: Backgrounds

    public struct Labels: Equatable {
        public var selectedCellTextColor: UIColor
        public var unselectedCellTextColor: UIColor
        public var focusedCellTextColor: UIColor
        public var disabledCellTextColor: UIColor
        public var font: UIFontDescriptor?
        public var focusedFont: UIFontDescriptor?

        public init(
            selectedCellTextColor: UIColor,
            unselectedCellTextColor: UIColor,
            focusedCellTextColor: UIColor,
            disabledCellTextColor: UIColor,
            font: UIFontDescriptor? = nil,
            focusedFont: UIFontDescriptor? = nil
        ) {
            self.selectedCellTextColor = selectedCellTextColor
            self.unselectedCellTextColor = unselectedCellTextColor
            self.focusedCellTextColor = focusedCellTextColor
            self.disabledCellTextColor = disabledCellTextColor
            self.font = font
            self.focusedFont = focusedFont
        }
    }
    public var labels: Labels

    public init(
        componentSpacing: CGFloat,
        backgrounds: Backgrounds,
        labels: Labels
    ) {
        self.componentSpacing = componentSpacing
        self.backgrounds = backgrounds
        self.labels = labels
    }
}

extension TVOSPickerViewStyle {
    public static let `default` = TVOSPickerViewStyle(
        componentSpacing: 0,
        backgrounds: .init(
            selectedCellBackgroundColor: .lightGray,
            focusedCellBackgroundColor: .white
        ),
        labels: .init(
            selectedCellTextColor: .black,
            unselectedCellTextColor: .white,
            focusedCellTextColor: .black,
            disabledCellTextColor: .white.withAlphaComponent(0.3)
        )
    )
}
