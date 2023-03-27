//  Copyright © 2023 Paramount. All rights reserved.

import Foundation

private func ordinalNumberFormatter(withLocale locale: Locale) -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .ordinal
    return formatter
}

/// Supports only Gregorian calendar.
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
    private let minYear: Int
    private let maxYear: Int
    public private(set) var date: Date

    public init(
        order: DateComponentsOrder = .monthDayYear,
        locale: Locale = .autoupdatingCurrent,
        minYear: Int = 1900,
        maxYear: Int? = nil,
        initialDate: Date = Date(),
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
        self.minYear = minYear
        self.maxYear = maxYear ?? calendar.component(.year, from: Date())
        precondition(self.minYear <= self.maxYear, "DatePickerDataSource misconfigured! maxYear has to be greater or equal to minYear")
        self.date = initialDate
        let year = calendar.component(.year, from: self.date)
        precondition(year >= self.minYear && year <= self.maxYear, "DatePickerDataSource misconfigured! initialDate has to be in range of minYear...maxYear")

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
            return (minYear...maxYear).count
        default:
            return 0
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
            let current = calendar.component(.year, from: date)
            let diff = (minYear + row) - current
            guard diff != 0 else { break }
            let currentDaysCount = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
            date = calendar.date(byAdding: .year, value: diff, to: date, wrappingComponents: true) ?? date
            let newDaysCount = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
            if newDaysCount != currentDaysCount {
                pickerView.reloadComponent(index(ofDateComponent: .day))
            }
        default:
            break
        }
    }
}
