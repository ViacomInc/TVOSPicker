//  Copyright © 2023 Paramount. All rights reserved.

import Foundation

public protocol TVOSPickerViewDelegate: AnyObject {
    func numberOfComponents(in pickerView: TVOSPickerView) -> Int
    func pickerView(_ pickerView: TVOSPickerView, numberOfRowsInComponent component: Int) -> Int
    func pickerView(_ pickerView: TVOSPickerView, widthForComponent component: Int) -> CGFloat
    func pickerView(_ pickerView: TVOSPickerView, titleForRow row: Int, inComponent component: Int) -> String?
    func pickerView(_ pickerView: TVOSPickerView, accessibilityStringForRow row: Int, inComponent component: Int) -> String?
    func pickerView(_ pickerView: TVOSPickerView, didSelectRow row: Int, inComponent component: Int)
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
}
