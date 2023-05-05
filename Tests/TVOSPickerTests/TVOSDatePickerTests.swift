import XCTest
@testable import TVOSPicker

final class TVOSDatePickerTests: XCTestCase {
    func testGregorianCalendarDatePickerDelegate_BasicDelegateMethods() throws {
        let initialDate = DateComponents(calendar: Calendar.current, year: 2000, month: 3, day: 15).date!
        let delegate = GregorianCalendarDatePickerDelegate(
            order: .monthDayYear,
            locale: .init(identifier: "en_US"),
            minDate: DateComponents(calendar: Calendar.current, year: 1900, month: 1, day: 1).date!,
            maxDate: DateComponents(calendar: Calendar.current, year: 2023, month: 12, day: 31).date!,
            initialDate: initialDate,
            offLimitYearsDisplayed: 0
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
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 0), nil)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 1), nil)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 2), nil)
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
            minDate: DateComponents(calendar: Calendar.current, year: 1900, month: 1, day: 1).date!,
            maxDate: DateComponents(calendar: Calendar.current, year: 2023, month: 12, day: 31).date!,
            initialDate: initialDate,
            offLimitYearsDisplayed: 0
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
            minDate: DateComponents(calendar: Calendar.current, year: 1900, month: 1, day: 1).date!,
            maxDate: DateComponents(calendar: Calendar.current, year: 2023, month: 12, day: 31).date!,
            initialDate: initialDate,
            offLimitYearsDisplayed: 0
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

    func testGregorianCalendarDatePickerDelegate_RangeOfAllowedRows() {
        let minDate = DateComponents(calendar: Calendar.current, year: 1991, month: 7, day: 3).date!
        let maxDate = DateComponents(calendar: Calendar.current, year: 2000, month: 3, day: 15).date!
        let initialDate = DateComponents(calendar: Calendar.current, year: 1995, month: 2, day: 4).date!
        let offLimitYearsDisplayed = 100
        let delegate = GregorianCalendarDatePickerDelegate(
            order: .monthDayYear,
            locale: .init(identifier: "en_US"),
            minDate: minDate,
            maxDate: maxDate,
            initialDate: initialDate,
            offLimitYearsDisplayed: offLimitYearsDisplayed
        )
        let datePicker = TVOSDatePickerView(delegate: delegate)

        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 0), nil) // all months allowed
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 1), nil) // all days allowed
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 2), offLimitYearsDisplayed...(offLimitYearsDisplayed + 9)) // 10 years (1991-2000) allowed, 100 off limits years displayed additionally before and after the allowed range

        delegate.pickerView(datePicker.pickerView, didSelectRow: offLimitYearsDisplayed, inComponent: 2) // selected minYear
        // date changed to minDate
        XCTAssertEqual(delegate.date, minDate)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 0), 6...11) // only months from Jul to Dec allowed
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 1), 2...30) // only days from 3rd to 31st allowed

        delegate.pickerView(datePicker.pickerView, didSelectRow: offLimitYearsDisplayed + 1, inComponent: 2) // selected minYear + 1
        XCTAssertEqual(delegate.date, DateComponents(calendar: Calendar.current, year: 1992, month: 7, day: 3).date!)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 0), nil) // all months allowed
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 1), nil) // all days allowed

        // select 12th of December
        delegate.pickerView(datePicker.pickerView, didSelectRow: 11, inComponent: 0)
        delegate.pickerView(datePicker.pickerView, didSelectRow: 11, inComponent: 1)
        XCTAssertEqual(delegate.date, DateComponents(calendar: Calendar.current, year: 1992, month: 12, day: 12).date!)

        // select max year
        delegate.pickerView(datePicker.pickerView, didSelectRow: 109, inComponent: 2)
        // date changed to maxDate
        XCTAssertEqual(delegate.date, maxDate)
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 0), 0...2) // only months from Jan to Mar allowed
        XCTAssertEqual(delegate.pickerView(datePicker.pickerView, rangeOfAllowedRowsInComponent: 1), 0...14) // only days from 1st to 15th allowed
    }

    func testGregorianCalendarDatePickerDelegate_CallingDatePicker_onDateChanged_closure() {
        let minDate = DateComponents(calendar: Calendar.current, year: 1991, month: 7, day: 3).date!
        let maxDate = DateComponents(calendar: Calendar.current, year: 2000, month: 3, day: 15).date!
        let initialDate = DateComponents(calendar: Calendar.current, year: 1995, month: 2, day: 4).date!
        let offLimitYearsDisplayed = 100
        let delegate = GregorianCalendarDatePickerDelegate(
            order: .monthDayYear,
            locale: .init(identifier: "en_US"),
            minDate: minDate,
            maxDate: maxDate,
            initialDate: initialDate,
            offLimitYearsDisplayed: offLimitYearsDisplayed
        )
        let datePicker = TVOSDatePickerView(delegate: delegate)

        var selectedDate: Date? = nil
        datePicker.onDateChanged = { date in
            selectedDate = date
        }

        // select 12th of December
        delegate.pickerView(datePicker.pickerView, didSelectRow: 11, inComponent: 0)
        delegate.pickerView(datePicker.pickerView, didSelectRow: 11, inComponent: 1)

        XCTAssertEqual(delegate.date, selectedDate)
    }
}
