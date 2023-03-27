import XCTest
@testable import TVOSPicker

final class TVOSDatePickerTests: XCTestCase {
    func testGregorianCalendarDatePickerDelegate_BasicDelegateMethods() throws {
        let initialDate = DateComponents(calendar: Calendar.current, year: 2000, month: 3, day: 15).date!
        let delegate = GregorianCalendarDatePickerDelegate(
            order: .monthDayYear,
            locale: .init(identifier: "en_US"),
            minYear: 1900,
            maxYear: 2023,
            initialDate: initialDate
        )
        let datePicker = TVOSDatePickerView(delegate: delegate)
        XCTAssertEqual(datePicker.style, .datePicker)
        XCTAssertEqual(datePicker.pickerView.style, .datePicker)
        XCTAssert(datePicker.delegate === delegate)
        XCTAssert(datePicker.pickerView.delegate === delegate)

        XCTAssertEqual(delegate.date, initialDate)
        XCTAssertEqual(delegate.numberOfComponents(in: datePicker.pickerView), 3)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, numberOfRowsInComponent: 0), 12)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, numberOfRowsInComponent: 1), 31)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, numberOfRowsInComponent: 2), 124)
        XCTAssertEqual(delegate.indexOfSelectedRow(inComponent: 0, ofPickerView: datePicker.pickerView), 2)
        XCTAssertEqual(delegate.indexOfSelectedRow(inComponent: 1, ofPickerView: datePicker.pickerView), 14)
        XCTAssertEqual(delegate.indexOfSelectedRow(inComponent: 2, ofPickerView: datePicker.pickerView), 100)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, titleForRow: 0, inComponent: 0), "Jan")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, titleForRow: 0, inComponent: 1), "01")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, titleForRow: 0, inComponent: 2), "1900")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, accessibilityStringForRow: 0, inComponent: 0), "January")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, accessibilityStringForRow: 0, inComponent: 1), "1st")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, accessibilityStringForRow: 0, inComponent: 2), "1900")
    }

    func testGregorianCalendarDatePickerDelegate_FebruaryAndLeapYears() {
        let initialDate = DateComponents(calendar: Calendar.current, year: 2000, month: 3, day: 15).date!
        let delegate = GregorianCalendarDatePickerDelegate(
            order: .monthDayYear,
            locale: .init(identifier: "en_US"),
            minYear: 1900,
            maxYear: 2023,
            initialDate: initialDate
        )
        let datePicker = TVOSDatePickerView(delegate: delegate)

        // set day to 31st of March
        delegate.pickerView(datePicker.pickerView, didSelectRow: 30, inComponent: 1)
        XCTAssertEqual(delegate.indexOfSelectedRow(inComponent: 1, ofPickerView: datePicker.pickerView), 30)

        // set month to February
        delegate.pickerView(datePicker.pickerView, didSelectRow: 1, inComponent: 0)
        XCTAssertEqual(delegate.indexOfSelectedRow(inComponent: 0, ofPickerView: datePicker.pickerView), 1)

        // day should also change to 29th because February 2000 has 29 days
        XCTAssertEqual(delegate.indexOfSelectedRow(inComponent: 1, ofPickerView: datePicker.pickerView), 28)

        // set year to 2001
        delegate.pickerView(datePicker.pickerView, didSelectRow: 101, inComponent: 2)
        XCTAssertEqual(delegate.indexOfSelectedRow(inComponent: 2, ofPickerView: datePicker.pickerView), 101)

        // day should also change to 28th because February 2001 has 28 days
        XCTAssertEqual(delegate.indexOfSelectedRow(inComponent: 1, ofPickerView: datePicker.pickerView), 27)

        XCTAssertEqual(datePicker.date, DateComponents(calendar: Calendar.current, year: 2001, month: 2, day: 28).date!)
    }

    func testGregorianCalendarDatePickerDelegate_OrdersAndLocales() {
        let initialDate = DateComponents(calendar: Calendar.current, year: 2000, month: 3, day: 15).date!
        let delegate = GregorianCalendarDatePickerDelegate(
            order: .dayMonthYear,
            locale: .init(identifier: "pl"),
            minYear: 1900,
            maxYear: 2023,
            initialDate: initialDate
        )
        let datePicker = TVOSDatePickerView(delegate: delegate)
        XCTAssertEqual(delegate.date, initialDate)
        XCTAssertEqual(delegate.numberOfComponents(in: datePicker.pickerView), 3)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, numberOfRowsInComponent: 0), 31)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, numberOfRowsInComponent: 1), 12)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, numberOfRowsInComponent: 2), 124)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, titleForRow: 0, inComponent: 0), "01")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, titleForRow: 0, inComponent: 1), "sty")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, titleForRow: 0, inComponent: 2), "1900")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, accessibilityStringForRow: 0, inComponent: 0), "1.")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, accessibilityStringForRow: 0, inComponent: 1), "stycznia")
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, accessibilityStringForRow: 0, inComponent: 2), "1900")
    }

    func testGregorianCalendarDatePickerDelegate_ChangeStyleAndDelegate() {
        let delegate1 = GregorianCalendarDatePickerDelegate()
        let picker = TVOSDatePickerView(delegate: delegate1)
        XCTAssert(picker.delegate === delegate1)
        XCTAssert(picker.pickerView.delegate === delegate1)
        let delegate2 = GregorianCalendarDatePickerDelegate()
        picker.delegate = delegate2
        XCTAssert(picker.delegate === delegate2)
        XCTAssert(picker.pickerView.delegate === delegate2)

        XCTAssertEqual(picker.style, .datePicker)
        XCTAssertEqual(picker.style, picker.pickerView.style)
        picker.style = .default
        XCTAssertEqual(picker.style, .default)
        XCTAssertEqual(picker.style, picker.pickerView.style)
    }
}
