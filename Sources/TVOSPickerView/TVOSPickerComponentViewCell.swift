//  Copyright © 2023 Paramount. All rights reserved.

import UIKit

class TVOSPickerComponentViewCell: UITableViewCell {
    static let reuseIdentifier = "\(TVOSPickerComponentViewCell.self)"

    private let label = UILabel()
    private let maskedLabel = UILabel()
    private let labelMask = CALayer()

    private var style: TVOSPickerViewStyle.Labels?
    private var font: UIFont?
    private var focusedFont: UIFont?

    private var focusInsideParent = false

    private var getAccessibilityLabel: (() -> String?)?
    override var accessibilityLabel: String? {
        get { getAccessibilityLabel?() }
        set { }
    }

    private var getAccessibilityTraits: (() -> UIAccessibilityTraits)?
    override var accessibilityTraits: UIAccessibilityTraits {
        get { getAccessibilityTraits?() ?? .none }
        set { }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        focusStyle = .custom
        if #available(tvOS 14, *) {
            backgroundConfiguration = .clear()
        }
        setupLabels()
        setupMask()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabels() {
        [label, maskedLabel].forEach {
            $0.textAlignment = .center
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                $0.topAnchor.constraint(equalTo: contentView.topAnchor),
                $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        maskedLabel.layer.mask = labelMask
    }

    private func setupMask() {
        labelMask.backgroundColor = UIColor.black.cgColor
        labelMask.opacity = 1
        labelMask.frame = .zero
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        maskedLabel.text = ""
        focusInsideParent = false
    }

    func maskLabel(with rect: CGRect) {
        var intersection = frame.intersection(rect)
        intersection = intersection.isNull ? .zero : intersection
        intersection = intersection.offsetBy(dx: -frame.origin.x, dy: -frame.origin.y)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        labelMask.frame = intersection
        CATransaction.commit()
    }

    func configure(
        title: String?,
        style: TVOSPickerViewStyle.Labels
    ) {
        label.text = title
        maskedLabel.text = title
        label.textColor = style.unselectedCellTextColor
        maskedLabel.textColor = focusInsideParent ? style.focusedCellTextColor : style.selectedCellTextColor

        self.style = style
        self.font = style.font.map { UIFont(descriptor: $0, size: $0.pointSize) }
        self.focusedFont = style.focusedFont.map { UIFont(descriptor: $0, size: $0.pointSize) } ?? self.font
        if let font {
            label.font = font
            maskedLabel.font = font
        }
        if let focusedFont, focusInsideParent {
            maskedLabel.font = focusedFont
        }
    }

    func configureAccessibility(
        label: @escaping () -> String?,
        traits: @escaping () -> UIAccessibilityTraits,
        frame: CGRect
    ) {
        isAccessibilityElement = true
        getAccessibilityLabel = label
        getAccessibilityTraits = traits
        self.accessibilityFrame = frame
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if let superview, context.nextFocusedView?.isDescendant(of: superview) == true {
            if !focusInsideParent {
                focusInsideParent = true
                maskedLabel.textColor = style?.focusedCellTextColor
                maskedLabel.font = focusedFont ?? label.font
            }
        } else {
            if focusInsideParent {
                focusInsideParent = false
                maskedLabel.textColor = style?.selectedCellTextColor
                maskedLabel.font = font ?? label.font
            }
        }
    }
}

// This prevents VoiceOver from reading, e.g. "third of twelve"
extension TVOSPickerComponentViewCell: UIAccessibilityContainerDataTableCell {
    func accessibilityRowRange() -> NSRange {
        .init(location: NSNotFound, length: 0)
    }

    func accessibilityColumnRange() -> NSRange {
        .init(location: NSNotFound, length: 0)
    }
}
