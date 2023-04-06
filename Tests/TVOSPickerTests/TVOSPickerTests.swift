import XCTest
@testable import TVOSPicker

final class TVOSPickerTests: XCTestCase {
    func testPickerDelegateCommunication() throws {
        let delegate = MockPickerDelegate(columnCounts: [10, 100, 12, 6])
        var style = TVOSPickerViewStyle.default
        style.componentSpacing = 10
        let picker = TVOSPickerView(style: style)

        // nothing happens because delegate is nil
        picker.reloadData()
        XCTAssertEqual(picker.components.count, 0)
        XCTAssertEqual(delegate.numberOfComponentsMethodCalls, 0)
        XCTAssertEqual(delegate.numberOfRowsInComponentMethodCalls, 0)
        XCTAssertEqual(delegate.rangeOfAllowedRowsInComponentMethodCalls, 0)
        XCTAssertEqual(delegate.indexOfSelectedRowMethodCalls, 0)
        XCTAssertEqual(delegate.didSelectRowMethodCalls, 0)

        picker.delegate = delegate

        // nothing happens because frame.width is 0
        picker.reloadData()
        XCTAssertEqual(picker.components.count, 0)
        XCTAssertEqual(delegate.numberOfComponentsMethodCalls, 0)
        XCTAssertEqual(delegate.numberOfRowsInComponentMethodCalls, 0)
        XCTAssertEqual(delegate.rangeOfAllowedRowsInComponentMethodCalls, 0)
        XCTAssertEqual(delegate.indexOfSelectedRowMethodCalls, 0)
        XCTAssertEqual(delegate.didSelectRowMethodCalls, 0)

        picker.frame = .init(x: 0, y: 0, width: 1000, height: 1000)
        picker.reloadData()

        XCTAssertEqual(picker.components.count, 4)
        for component in picker.components {
            XCTAssertEqual(component.style, style)
            XCTAssert(component.delegate === picker)
            XCTAssertEqual(component.widthConstraint?.constant, (1000 - 3 * 10) / 4)
        }

        // called once to get the number of component views to create
        // called 4 additional times for each component by the default implementation of `widthForComponent` delegate method (to divide width by number of components)
        XCTAssertEqual(delegate.numberOfComponentsMethodCalls, 5)

        // called once per component
        XCTAssertEqual(delegate.rangeOfAllowedRowsInComponentMethodCalls, 4)
        XCTAssertEqual(delegate.numberOfRowsInComponentMethodCalls, 4)
        XCTAssertEqual(delegate.indexOfSelectedRowMethodCalls, 4)
        XCTAssertEqual(delegate.didSelectRowMethodCalls, 4)

        delegate.columnCounts.removeLast(2)
        delegate.numberOfComponentsMethodCalls = 0
        delegate.numberOfRowsInComponentMethodCalls = 0
        delegate.rangeOfAllowedRowsInComponentMethodCalls = 0
        delegate.didSelectRowMethodCalls = 0
        delegate.indexOfSelectedRowMethodCalls = 0
        picker.reloadData()

        XCTAssertEqual(picker.components.count, 2)
        for component in picker.components {
            XCTAssertEqual(component.style, style)
            XCTAssert(component.delegate === picker)
            XCTAssertEqual(component.widthConstraint?.constant, (1000 - 10) / 2)
        }

        XCTAssertEqual(delegate.numberOfComponentsMethodCalls, 3)

        // called once per component
        XCTAssertEqual(delegate.numberOfRowsInComponentMethodCalls, 2)
        XCTAssertEqual(delegate.rangeOfAllowedRowsInComponentMethodCalls, 2)
        XCTAssertEqual(delegate.indexOfSelectedRowMethodCalls, 2)
        XCTAssertEqual(delegate.didSelectRowMethodCalls, 2)

        var newStyle = TVOSPickerViewStyle.default
        newStyle.labels.focusedCellTextColor = .orange
        picker.style = newStyle
        for component in picker.components {
            XCTAssertEqual(component.style, picker.style)
        }
    }
}

class MockPickerDelegate: TVOSPickerViewDelegate {
    var columnCounts: [Int]
    var selected: [Int]

    var numberOfComponentsMethodCalls = 0
    var numberOfRowsInComponentMethodCalls = 0
    var rangeOfAllowedRowsInComponentMethodCalls = 0
    var didSelectRowMethodCalls = 0
    var indexOfSelectedRowMethodCalls = 0

    init(columnCounts: [Int]) {
        self.columnCounts = columnCounts
        self.selected = Array(repeating: 0, count: columnCounts.count)
    }

    func numberOfComponents(in pickerView: TVOSPickerView) -> Int {
        numberOfComponentsMethodCalls += 1
        return columnCounts.count
    }

    func pickerView(_ pickerView: TVOSPickerView, numberOfRowsInComponent component: Int) -> Int {
        numberOfRowsInComponentMethodCalls += 1
        return columnCounts[component]
    }

    func pickerView(_ pickerView: TVOSPickerView, rangeOfAllowedRowsInComponent component: Int) -> ClosedRange<Int>? {
        rangeOfAllowedRowsInComponentMethodCalls += 1
        return nil
    }

    func pickerView(_ pickerView: TVOSPickerView, titleForRow row: Int, inComponent component: Int) -> String? {
        String("\(component):\(row)")
    }

    func pickerView(_ pickerView: TVOSPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectRowMethodCalls += 1
        selected[component] = row
    }

    func indexOfSelectedRow(inComponent component: Int, ofPickerView pickerView: TVOSPickerView) -> Int? {
        indexOfSelectedRowMethodCalls += 1
        return selected[component]
    }
}
