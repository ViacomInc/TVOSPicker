//  Copyright © 2023 Paramount. All rights reserved.

import UIKit

extension TVOSPickerViewStyle {
    public static let datePicker = TVOSPickerViewStyle(
        componentSpacing: 56,
        backgrounds: .init(
            selectedCellBackgroundColor: .clear,
            focusedCellBackgroundColor: .white
        ),
        labels: .init(
            selectedCellTextColor: .white,
            unselectedCellTextColor: .white.withAlphaComponent(0.3),
            focusedCellTextColor: .black,
            font: UIFontDescriptor().withSize(48),
            focusedFont: {
                let descriptor = UIFontDescriptor().withSize(48)
                return descriptor.withSymbolicTraits([descriptor.symbolicTraits, .traitBold])
            }()
        )
    )
}

/// This component displays a `TVOSPickerView` restricting its delegate object to be
/// an instance of `GregorianCalendarDatePickerDelegate` class.
public class TVOSDatePickerView: UIView {
    internal let pickerView: TVOSPickerView

    public var style: TVOSPickerViewStyle {
        didSet {
            pickerView.style = style
        }
    }

    public var delegate: GregorianCalendarDatePickerDelegate? {
        didSet {
            pickerView.delegate = delegate
        }
    }

    public var date: Date? {
        delegate?.date
    }

    public override var preferredFocusEnvironments: [UIFocusEnvironment] {
        pickerView.preferredFocusEnvironments
    }

    public init(delegate: GregorianCalendarDatePickerDelegate? = nil) {
        self.delegate = delegate
        self.style = .datePicker
        self.pickerView = .init(style: self.style, delegate: delegate)

        super.init(frame: .zero)

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        accessibilityElements = [pickerView]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func reloadData() {
        pickerView.reloadData()
    }

    public func reloadComponents(_ indices: IndexSet) {
        pickerView.reloadComponents(indices)
    }

    public func reloadComponent(_ index: Int) {
        pickerView.reloadComponent(index)
    }
}
