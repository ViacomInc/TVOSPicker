//  Copyright © 2023 Paramount. All rights reserved.

import Foundation

public protocol TVOSPickerViewDelegate: AnyObject {
    /// Number of columns in the picker view.
    func numberOfComponents(in pickerView: TVOSPickerView) -> Int

    /// Number of rows in a given column of the picker view.
    func pickerView(_ pickerView: TVOSPickerView, numberOfRowsInComponent component: Int) -> Int

    func pickerView(_ pickerView: TVOSPickerView, rangeOfAllowedRowsInComponent component: Int) -> ClosedRange<Int>?

    /// Optionally implement this method to customize width of each column of the picker view. By default, width of the picker view is divided equally between columns (accounting for `style.componentSpacing`).
    func pickerView(_ pickerView: TVOSPickerView, widthForComponent component: Int) -> CGFloat

    /// Provide a string to be displayed in each row in a given column of the picker view.
    func pickerView(_ pickerView: TVOSPickerView, titleForRow row: Int, inComponent component: Int) -> String?

    /// Optionally implement this method to provide a custom string to be read by VoiceOver for each row in a given column of the picker view. By default, VoiceOver will read the string provided in `titleForRow` method.
    func pickerView(_ pickerView: TVOSPickerView, accessibilityStringForRow row: Int, inComponent component: Int) -> String?

    /// Callback called whenever a new row is selected. Implement to update the state accordingly.
    func pickerView(_ pickerView: TVOSPickerView, didSelectRow row: Int, inComponent component: Int)

    /// Optionally provide an index that will be focused and selected initially and after each call to picker view's `reload*` methods.
    func indexOfSelectedRow(inComponent component: Int, ofPickerView pickerView: TVOSPickerView) -> Int?
}

public extension TVOSPickerViewDelegate {
    func pickerView(_ pickerView: TVOSPickerView, widthForComponent component: Int) -> CGFloat {
        let componentsCount = self.numberOfComponents(in: pickerView)
        guard componentsCount > 0 else { return 0 }
        let spacing = pickerView.style.componentSpacing
        let componentsWidth = pickerView.frame.width - spacing * CGFloat(componentsCount - 1)
        return componentsWidth / CGFloat(componentsCount)
    }

    func pickerView(_ pickerView: TVOSPickerView, accessibilityStringForRow row: Int, inComponent component: Int) -> String? {
        self.pickerView(pickerView, titleForRow: row, inComponent: component)
    }

    func pickerView(_ pickerView: TVOSPickerView, rangeOfAllowedRowsInComponent component: Int) -> ClosedRange<Int>? {
        nil
    }
}
