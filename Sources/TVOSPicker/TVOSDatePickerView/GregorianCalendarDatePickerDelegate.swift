//  Copyright © 2023 Paramount. All rights reserved.

import Foundation

private func ordinalNumberFormatter(withLocale locale: Locale) -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .ordinal
    return formatter
}

/// `GregorianCalendarDatePickerDelegate` is a class conforming to `TVOSPickerViewDelegate`
/// that can be used with `TVOSDatePickerView` to display a date picker allowing users to select a date
/// that is valid in Gregorian calendar using 3 picker components for day, month and year.
public class GregorianCalendarDatePickerDelegate {
    public enum DateComponentsOrder {
        case dayMonthYear
        case monthDayYear
        case yearMonthDay

        var dateComponents: [Calendar.Component] {
            switch self {
            case .dayMonthYear: return [.day, .month, .year]
            case .monthDayYear: return [.month, .day, .year]
            case .yearMonthDay: return [.year, .month, .day]
            }
        }
    }
    private let order: DateComponentsOrder

    private let locale: Locale
    private var calendar = Calendar(identifier: .gregorian)

    private let stringFromMonthIndex: (Int) -> String
    private let accessibilityStringFromMonthIndex: (Int) -> String
    private let stringFromDayIndex: (Int) -> String
    private let accessibilityStringFromDayIndex: (Int) -> String
    private let stringFromYear: (Int) -> String
    private let accessibilityStringFromYear: (Int) -> String

    private let minDate: Date
    private lazy var minYear = calendar.component(.year, from: minDate)

    private let maxDate: Date
    private lazy var maxYear = calendar.component(.year, from: maxDate)

    public private(set) var date: Date

    /// Returns a new GregorianCalendarDatePickerDelegate
    ///
    /// - parameter order: (Optional) The order in which day, month and year components are displayed in the picker view. Defaults to `.monthDayYear`.
    /// - parameter locale: (Optional) Locale used to localize ordinal numbers, month names etc. Defaults to `.autoupdatingCurrent`.
    /// - parameter minDate: (Optional) The minimum date that is allowed to be selected in the picker view. Defaults to 1st of January, 1900.
    /// - parameter maxDate: (Optional) The maximum date that is allowed to be selected in the picker view. Must be greater than or equal to `minDate`. Defaults to current date.
    /// - parameter initialDate: (Optional) The date that is selected by default in the picker view. Defaults to current date. This date must be in range between `minDate` and `maxDate`.
    /// - parameter stringFromMonthIndex: (Optional) Closure used to provide a string that will be displayed for a given row in the month component of the picker view. Defaults to using `Calendar.shortMonthSymbols`, e.g. "Jan" for "January".
    /// - parameter accessibilityStringFromMonthIndex: (Optional) Closure used to provide a string that will be read by VoiceOver for a given row in the month component of the picker view. Defaults to using `Calendar.monthSymbols`, e.g. "January".
    /// - parameter stringFromDayIndex: (Optional) Closure used to provide a string that will be displayed for a given row in the day component of the picker view. Defaults to the number with 0 padding, e.g. "01", "02", ..., "25", ..., etc.
    /// - parameter accessibilityStringFromDayIndex: (Optional) Closure used to provide a string that will be read by VoiceOver for a given row in the day component of the picker view. Defaults to using a `NumberFormatter` with `numberStyle = .ordinal`, e.g. "1st" for first day, "3rd" for third day etc.
    /// - parameter stringFromYear: (Optional) Closure used to provide a string that will be displayed for a given row in the year component of the picker view. Defaults to the number, e.g. "2023".
    /// - parameter accessibilityStringFromYear: (Optional) Closure used to provide a string that will be read by VoiceOver for a given row in the year component of the picker view. Defaults to the number, e.g. "2023".
    public init(
        order: DateComponentsOrder = .monthDayYear,
        locale: Locale = .autoupdatingCurrent,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        initialDate: Date? = nil,
        stringFromMonthIndex: ((Int) -> String)? = nil,
        accessibilityStringFromMonthIndex: ((Int) -> String)? = nil,
        stringFromDayIndex: ((Int) -> String)? = nil,
        accessibilityStringFromDayIndex: ((Int) -> String)? = nil,
        stringFromYear: ((Int) -> String)? = nil,
        accessibilityStringFromYear: ((Int) -> String)? = nil
    ) {
        self.order = order
        self.locale = locale
        calendar.locale = locale
        let now = Date()
        self.minDate = minDate ?? calendar.date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? now
        self.maxDate = maxDate ?? now
        precondition(self.minDate <= self.maxDate, "DatePickerDataSource misconfigured! maxDate has to be greater or equal to minDate")
        self.date = initialDate ?? now
        precondition(self.date >= self.minDate && self.date <= self.maxDate, "DatePickerDataSource misconfigured! initialDate has to be in range of minDate...maxDate")

        self.stringFromMonthIndex = stringFromMonthIndex ?? { [calendar] monthIndex in
            calendar.shortMonthSymbols[monthIndex]
        }
        self.accessibilityStringFromMonthIndex = accessibilityStringFromMonthIndex ?? { [calendar] monthIndex in
            calendar.monthSymbols[monthIndex]
        }
        let stringFromDayIndex = stringFromDayIndex ?? { dayIndex in
            String(format: "%02d", dayIndex + 1)
        }
        self.stringFromDayIndex = stringFromDayIndex
        let ordinalFormatter = ordinalNumberFormatter(withLocale: locale)
        self.accessibilityStringFromDayIndex = accessibilityStringFromDayIndex ?? { dayIndex in
            ordinalFormatter.string(from: (dayIndex + 1) as NSNumber) ?? stringFromDayIndex(dayIndex)
        }
        self.stringFromYear = stringFromYear ?? { year in String(year) }
        self.accessibilityStringFromYear = accessibilityStringFromYear ?? { year in String(year) }
    }

    private func dateComponent(forIndex index: Int) -> Calendar.Component {
        order.dateComponents[index]
    }

    private func index(ofDateComponent component: Calendar.Component) -> Int {
        order.dateComponents.firstIndex(of: component) ?? 0
    }
}

extension GregorianCalendarDatePickerDelegate: TVOSPickerViewDelegate {
    public func numberOfComponents(in pickerView: TVOSPickerView) -> Int {
        3
    }

    public func pickerView(_ pickerView: TVOSPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch dateComponent(forIndex: component) {
        case .month:
            return calendar.range(of: .month, in: .year, for: date)?.count ?? 0
        case .day:
            return calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        case .year:
            return maxYear - minYear + 1
        default:
            return 0
        }
    }

    public func pickerView(_ pickerView: TVOSPickerView, rangeOfAllowedRowsInComponent component: Int) -> ClosedRange<Int>? {
        switch dateComponent(forIndex: component) {
        case .month:
            let currentYear = calendar.component(.year, from: date)
            if currentYear != minYear && currentYear != maxYear {
                return nil
            }
            var minMonthIndex = 0
            var maxMonthIndex = calendar.range(of: .month, in: .year, for: date).map { $0.count - 1 } ?? 0
            if currentYear == minYear {
                minMonthIndex = calendar.component(.month, from: minDate) - 1
            }
            if currentYear == maxYear {
                maxMonthIndex = calendar.component(.month, from: maxDate) - 1
            }
            return minMonthIndex...maxMonthIndex

        case .day:
            let currentYear = calendar.component(.year, from: date)
            if currentYear != minYear && currentYear != maxYear {
                return nil
            }
            var minDayIndex = 0
            var maxDayIndex = calendar.range(of: .day, in: .month, for: date).map { $0.count - 1 } ?? 0
            if currentYear == minYear {
                minDayIndex = calendar.component(.day, from: minDate) - 1
            }
            if currentYear == maxYear {
                maxDayIndex = calendar.component(.day, from: maxDate) - 1
            }
            return minDayIndex...maxDayIndex

        default:
            return nil
        }
    }

    public func pickerView(_ pickerView: TVOSPickerView, titleForRow row: Int, inComponent component: Int) -> String? {
        switch dateComponent(forIndex: component) {
        case .month:
            return stringFromMonthIndex(row)
        case .day:
            return stringFromDayIndex(row)
        case .year:
            return stringFromYear(minYear + row)
        default:
            return nil
        }
    }

    public func pickerView(_ pickerView: TVOSPickerView, accessibilityStringForRow row: Int, inComponent component: Int) -> String? {
        switch dateComponent(forIndex: component) {
        case .month:
            return accessibilityStringFromMonthIndex(row)
        case .day:
            return accessibilityStringFromDayIndex(row)
        case .year:
            return accessibilityStringFromYear(minYear + row)
        default:
            return nil
        }
    }

    public func indexOfSelectedRow(inComponent component: Int, ofPickerView pickerView: TVOSPickerView) -> Int? {
        switch dateComponent(forIndex: component) {
        case .month:
            return calendar.component(.month, from: date) - 1
        case .day:
            return calendar.component(.day, from: date) - 1
        case .year:
            return calendar.component(.year, from: date) - minYear
        default:
            return nil
        }
    }

    public func pickerView(_ pickerView: TVOSPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch dateComponent(forIndex: component) {
        case .month:
            let current = calendar.component(.month, from: date)
            let diff = (row + 1) - current
            guard diff != 0 else { break }
            date = calendar.date(byAdding: .month, value: diff, to: date, wrappingComponents: true) ?? date
            pickerView.reloadComponent(index(ofDateComponent: .day))
        case .day:
            let current = calendar.component(.day, from: date)
            let diff = (row + 1) - current
            guard diff != 0 else { break }
            date = calendar.date(byAdding: .day, value: diff, to: date, wrappingComponents: true) ?? date
        case .year:
            let currentYear = calendar.component(.year, from: date)
            let diff = (minYear + row) - currentYear
            guard diff != 0 else { break }

            var newDate = calendar.date(byAdding: .year, value: diff, to: date, wrappingComponents: true) ?? date

            let newYear = calendar.component(.year, from: newDate)
            var shouldUpdateLimits = false
            if newYear == minYear || currentYear == minYear {
                shouldUpdateLimits = true
                if newDate < minDate {
                    newDate = minDate
                }
            }
            if newYear == maxYear || currentYear == maxYear {
                shouldUpdateLimits = true
                if newDate > maxDate {
                    newDate = maxDate
                }
            }
            let currentDaysCount = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
            date = newDate
            let newDaysCount = calendar.range(of: .day, in: .month, for: date)?.count ?? 0

            var componentsToReload: Set<Calendar.Component> = []
            if newDaysCount != currentDaysCount || shouldUpdateLimits {
                componentsToReload.insert(.day)
            }
            if shouldUpdateLimits {
                componentsToReload.insert(.month)
            }
            pickerView.reloadComponents(IndexSet(componentsToReload.map(index(ofDateComponent:))))
        default:
            break
        }
    }
}
