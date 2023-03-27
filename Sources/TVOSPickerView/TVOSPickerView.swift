//  Copyright © 2023 Paramount. All rights reserved.

import Foundation
import UIKit

public class TVOSPickerView: UIView {
    private var firstReload = true
    private let stack = UIStackView()
    private var components: [TVOSPickerComponentView] = []

    public var lastFocusedComponentIndex: Int?

    public override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let lastFocusedComponentIndex,
           lastFocusedComponentIndex < components.count {
            return [components[lastFocusedComponentIndex]]
        }
        return components.first.map { [$0] } ?? []
    }

    public var style: TVOSPickerViewStyle {
        didSet {
            stack.spacing = style.componentSpacing
            components.forEach {
                $0.style = self.style
            }
        }
    }

    public weak var delegate: TVOSPickerViewDelegate? {
        didSet {
            reloadData()
        }
    }

    public init(style: TVOSPickerViewStyle, delegate: TVOSPickerViewDelegate? = nil) {
        self.style = style
        self.delegate = delegate
        super.init(frame: .zero)

        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = style.componentSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if firstReload {
            firstReload = false
            reloadData()
        }
    }

    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        guard let next = context.nextFocusedView,
              next.isDescendant(of: self)
        else { return }
        lastFocusedComponentIndex = components.firstIndex { component in
            next.isDescendant(of: component)
        }
    }
}

// MARK: Public API
extension TVOSPickerView {
    public func reloadData() {
        guard frame.width > 0 else { return }
        guard let delegate else { return }
        let componentsCount = delegate.numberOfComponents(in: self)
        guard componentsCount > 0 else { return }
        while components.count > componentsCount {
            let last = components.popLast()
            last?.removeFromSuperview()
        }
        while components.count < componentsCount {
            let new = TVOSPickerComponentView()
            new.style = style
            stack.addArrangedSubview(new)
            components.append(new)
            new.delegate = self
        }
        reloadComponents(IndexSet(integersIn: components.indices))

        accessibilityElements = components
    }

    public func reloadComponents(_ indices: IndexSet) {
        indices.forEach {
            let component = self.components[$0]
            if let width = self.delegate?.pickerView(self, widthForComponent: $0) {
                component.setupWidthConstraint(constant: width)
            }
            component.reloadData()
        }
    }

    public func reloadComponent(_ index: Int) {
        reloadComponents([index])
    }
}

// MARK: TVOSPickerComponentViewDelegate conformance
extension TVOSPickerView: TVOSPickerComponentViewDelegate {
    func numberOfItems(inPickerComponentView componentView: TVOSPickerComponentView) -> Int {
        guard let component = components.firstIndex(of: componentView),
              let delegate
        else { return 0 }
        return delegate.pickerView(self, numberOfRowsInComponent: component)
    }

    func pickerComponentView(_ componentView: TVOSPickerComponentView, titleForRow row: Int) -> String? {
        guard let component = components.firstIndex(of: componentView),
              let delegate
        else { return nil }
        return delegate.pickerView(self, titleForRow: row, inComponent: component)
    }

    func pickerComponentView(_ componentView: TVOSPickerComponentView, accessibilityStringForRow row: Int) -> String? {
        guard let component = components.firstIndex(of: componentView),
              let delegate
        else { return nil }
        return delegate.pickerView(self, accessibilityStringForRow: row, inComponent: component)
    }

    func pickerComponentView(_ componentView: TVOSPickerComponentView, didSelectRow row: Int) {
        guard let component = components.firstIndex(of: componentView) else { return }
        delegate?.pickerView(self, didSelectRow: row, inComponent: component)
    }

    func indexOfSelectedRow(inPickerComponentView componentView: TVOSPickerComponentView) -> Int? {
        guard let component = components.firstIndex(of: componentView) else { return nil }
        return delegate?.indexOfSelectedRow(inComponent: component, ofPickerView: self)
    }
}
