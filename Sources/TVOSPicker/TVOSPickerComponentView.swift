//  Copyright © 2023 Paramount. All rights reserved.

import UIKit

protocol TVOSPickerComponentViewDelegate: AnyObject {
    func numberOfItems(inPickerComponentView componentView: TVOSPickerComponentView) -> Int
    func pickerComponentView(_ componentView: TVOSPickerComponentView, didSelectRow row: Int)
    func pickerComponentView(_ componentView: TVOSPickerComponentView, titleForRow row: Int) -> String?
    func pickerComponentView(_ componentView: TVOSPickerComponentView, accessibilityStringForRow row: Int) -> String?
    func indexOfSelectedRow(inPickerComponentView componentView: TVOSPickerComponentView) -> Int?
}

class TVOSPickerComponentView: UIView {
    private enum Constants {
        static let cellBackgroundWidthMultiplier: CGFloat = 0.95
        static let cellBackgroundFocusedScale: CGFloat = 1.1
        static let rowHeight: CGFloat = 66
        static let cornerRadius: CGFloat = 12
    }

    private let tableView = UITableView()
    private let selectedCellBackground = UIView()
    private var widthConstraint: NSLayoutConstraint?

    private var focusInside = false

    weak var delegate: TVOSPickerComponentViewDelegate?

    var style: TVOSPickerViewStyle = .default {
        didSet {
            setupStyle()
        }
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let selected = tableView.indexPathForSelectedRow,
           let cell = tableView.cellForRow(at: selected) {
            return [cell]
        }
        return tableView.preferredFocusEnvironments
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
        setupSelectedCellBackground()
        setupAccessibility()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TVOSPickerComponentViewCell.self, forCellReuseIdentifier: TVOSPickerComponentViewCell.reuseIdentifier)
        tableView.remembersLastFocusedIndexPath = true
        tableView.decelerationRate = .fast
        tableView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupSelectedCellBackground() {
        selectedCellBackground.layer.cornerRadius = Constants.cornerRadius
        selectedCellBackground.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(selectedCellBackground, at: 0)
        NSLayoutConstraint.activate([
            selectedCellBackground.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedCellBackground.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectedCellBackground.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.cellBackgroundWidthMultiplier),
            selectedCellBackground.heightAnchor.constraint(equalToConstant: Constants.rowHeight)
        ])
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = ""
        if #available(tvOS 14, *) {
            accessibilityTraits = .adjustable
        } else {
            accessibilityTraits = .none
        }
        accessibilityElementsHidden = true
        tableView.accessibilityElementsHidden = true
        tableView.accessibilityContainerType = .none
    }

    private func setupStyle() {
        backgroundColor = .clear
        selectedCellBackground.backgroundColor = focusInside
            ? style.backgrounds.focusedCellBackgroundColor
            : style.backgrounds.selectedCellBackgroundColor
        tableView.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let verticalInset = 0.5 * tableView.bounds.height
        tableView.contentInset = .init(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
        guard let selected = tableView.indexPathForSelectedRow else { return }
        tableView.selectRow(at: selected, animated: false, scrollPosition: .middle)
        updateVisibleCellsMask()
    }

    private func updateVisibleCellsMask() {
        let middleRect = CGRect(
            x: 0,
            y: tableView.contentOffset.y + tableView.contentInset.top - selectedCellBackground.frame.height / 2,
            width: tableView.frame.width,
            height: selectedCellBackground.frame.height
        )
        tableView.visibleCells.forEach { cell in
            (cell as? TVOSPickerComponentViewCell)?.maskLabel(with: middleRect)
        }
    }

    private func didSelectRow(_ row: Int) {
        delegate?.pickerComponentView(self, didSelectRow: row)
        accessibilityLabel = delegate?.pickerComponentView(self, accessibilityStringForRow: row)
    }

    func reloadData() {
        tableView.reloadData()
        if let index = delegate?.indexOfSelectedRow(inPickerComponentView: self) {
            let path = IndexPath(item: index, section: 0)
            tableView.selectRow(at: path, animated: false, scrollPosition: .middle)
            didSelectRow(index)
        }
        updateVisibleCellsMask()
    }

    func setupWidthConstraint(constant: CGFloat) {
        widthConstraint?.isActive = false
        widthConstraint = widthAnchor.constraint(equalToConstant: constant)
        widthConstraint?.isActive = true
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if context.previouslyFocusedView?.isDescendant(of: self) == false,
           context.nextFocusedView?.isDescendant(of: self) == true {
            // remembersLastFocusedIndexPath prevents from force focusing custom index path in accessibilityIncrement/Decrement
            // but is needed initially to focus selected index path
            tableView.remembersLastFocusedIndexPath = false
        }
    }

// MARK: UIAccessibilityTraits.adjustable trait implementation

    private func accessibilitySelectRow(_ row: Int) {
        tableView.selectRow(at: IndexPath(item: row, section: 0), animated: true, scrollPosition: .middle)
        didSelectRow(row)
        UIAccessibility.post(notification: .announcement, argument: accessibilityLabel)
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }

    override func accessibilityDecrement() {
        super.accessibilityDecrement()
        guard let current = tableView.indexPathForSelectedRow?.item,
              current > 0
        else { return }
        accessibilitySelectRow(current - 1)
    }

    override func accessibilityIncrement() {
        super.accessibilityIncrement()
        guard let current = tableView.indexPathForSelectedRow?.item,
              let count = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0),
              current < count - 1
        else { return }
        accessibilitySelectRow(current + 1)
    }
}

// MARK: UITableViewDataSource conformance
extension TVOSPickerComponentView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        delegate?.numberOfItems(inPickerComponentView: self) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TVOSPickerComponentViewCell.reuseIdentifier, for: indexPath)
        if let cell = cell as? TVOSPickerComponentViewCell, let delegate {
            cell.configure(
                title: delegate.pickerComponentView(self, titleForRow: indexPath.item),
                style: style.labels
            )
            cell.configureAccessibility(
                label: { [weak self] in
                    self?.accessibilityLabel
                },
                traits: { .none },
                frame: convert(bounds, to: window)
            )
        }
        return cell
    }
}

// MARK: UITableViewDelegate conformance
extension TVOSPickerComponentView: UITableViewDelegate {
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        tableView.indexPathForSelectedRow
    }

    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let next = context.nextFocusedIndexPath else {
            if focusInside {
                focusInside = false
                coordinator.addCoordinatedAnimations {
                    self.selectedCellBackground.backgroundColor = self.style.backgrounds.selectedCellBackgroundColor
                    self.selectedCellBackground.transform = .identity
                }
            }
            return
        }
        if !focusInside {
            focusInside = true
            coordinator.addCoordinatedAnimations {
                self.selectedCellBackground.backgroundColor = self.style.backgrounds.focusedCellBackgroundColor
                self.selectedCellBackground.transform = .init(scaleX: Constants.cellBackgroundFocusedScale, y: Constants.cellBackgroundFocusedScale)
            }
        }
        tableView.selectRow(at: next, animated: false, scrollPosition: .none)
        didSelectRow(next.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVisibleCellsMask()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let selected = tableView.indexPathForSelectedRow,
              let frame = tableView.cellForRow(at: selected)?.frame
        else { return }
        targetContentOffset.pointee.y = frame.midY - 0.5 * tableView.bounds.height
    }
}
