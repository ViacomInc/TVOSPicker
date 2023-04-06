import UIKit
import TVOSPicker

class TimePickerDelegate: TVOSPickerViewDelegate {
    struct Time {
        var hours: Int
        var minutes: Int
    }
    var time: Time = .init(hours: 12, minutes: 37)

    func numberOfComponents(in pickerView: TVOSPickerView) -> Int {
        2
    }

    func pickerView(_ pickerView: TVOSPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return 24
        case 1: return 60
        default: fatalError()
        }
    }

    func pickerView(_ pickerView: TVOSPickerView, titleForRow row: Int, inComponent component: Int) -> String? {
        return String(format: "%02d", row)
    }

    func pickerView(_ pickerView: TVOSPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: time.hours = row
        case 1: time.minutes = row
        default: break
        }
    }

    func indexOfSelectedRow(inComponent component: Int, ofPickerView pickerView: TVOSPickerView) -> Int? {
        switch component {
        case 0: return time.hours
        case 1: return time.minutes
        default: return nil
        }
    }
}

class PlacePickerDelegate: TVOSPickerViewDelegate {
    let places = [
        "Paris, France",
        "London, United Kingdom",
        "Rome, Italy",
        "Bangkok, Thailand",
        "Tokyo, Japan",
        "Madrid, Spain",
        "Berlin, Germany",
        "Athens, Greece",
        "Seoul, South Korea",
        "Amsterdam, Netherlands",
        "Vienna, Austria",
        "Budapest, Hungary",
        "Prague, Czech Republic",
        "Lisbon, Portugal",
        "Dublin, Ireland",
        "Copenhagen, Denmark",
        "Brussels, Belgium",
        "Helsinki, Finland",
        "Stockholm, Sweden",
        "Warsaw, Poland",
        "Moscow, Russia",
        "Beijing, China",
        "New Delhi, India",
        "Jakarta, Indonesia",
        "Kuala Lumpur, Malaysia",
        "Hanoi, Vietnam",
        "Singapore City, Singapore",
        "Wellington, New Zealand",
        "Ottawa, Canada",
        "Washington D.C., United States",
        "Mexico City, Mexico",
        "Buenos Aires, Argentina",
        "Santiago, Chile",
        "Lima, Peru",
        "Quito, Ecuador",
        "Brasília, Brazil",
        "Bogotá, Colombia",
        "San José, Costa Rica",
        "Panama City, Panama",
        "San Salvador, El Salvador",
        "Tegucigalpa, Honduras",
        "Managua, Nicaragua",
        "Guatemala City, Guatemala",
        "Belmopan, Belize",
        "Nassau, Bahamas",
        "Kingston, Jamaica",
        "Port-au-Prince, Haiti",
        "Santo Domingo, Dominican Republic",
        "Havana, Cuba",
        "San Juan, Puerto Rico"
    ]
    var selectedPlaceIndex = 19

    func numberOfComponents(in pickerView: TVOSPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: TVOSPickerView, numberOfRowsInComponent component: Int) -> Int {
        places.count
    }

    func pickerView(_ pickerView: TVOSPickerView, rangeOfAllowedRowsInComponent component: Int) -> ClosedRange<Int>? {
        17...25
    }

    func pickerView(_ pickerView: TVOSPickerView, titleForRow row: Int, inComponent component: Int) -> String? {
        places[row]
    }

    func pickerView(_ pickerView: TVOSPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPlaceIndex = row
    }

    func indexOfSelectedRow(inComponent component: Int, ofPickerView pickerView: TVOSPickerView) -> Int? {
        selectedPlaceIndex
    }
}

class ViewController: UIViewController {
    var placePicker: TVOSPickerView!
    var timePicker: TVOSPickerView!
    let placePickerDelegate = PlacePickerDelegate()
    let timePickerDelegate = TimePickerDelegate()

    private func addPlacePicker() {
        let placePickerLabel = UILabel()
        placePickerLabel.font = .preferredFont(forTextStyle: .title2)
        placePickerLabel.text = "Pick a place"
        placePickerLabel.textAlignment = .center

        let placePicker = TVOSPickerView(style: .default, delegate: placePickerDelegate)
        self.placePicker = placePicker

        let placePickerStack = UIStackView(arrangedSubviews: [placePickerLabel, placePicker])
        placePickerStack.axis = .vertical
        placePickerStack.alignment = .fill
        placePickerStack.spacing = 80
        placePickerStack.distribution = .fill
        placePickerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placePickerStack)
        NSLayoutConstraint.activate([
            placePickerStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            placePickerStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2),
            placePickerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            placePickerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func addTimePicker() {
        let timePickerLabel = UILabel()
        timePickerLabel.font = .preferredFont(forTextStyle: .title2)
        timePickerLabel.text = "Pick a time"
        timePickerLabel.textAlignment = .center

        let timePickerStyle = TVOSPickerViewStyle(
            componentSpacing: 50,
            backgrounds: .init(
                selectedCellBackgroundColor: .orange,
                focusedCellBackgroundColor: .white
            ),
            labels: .init(
                selectedCellTextColor: .white,
                unselectedCellTextColor: .white.withAlphaComponent(0.3),
                focusedCellTextColor: .black,
                disabledCellTextColor: .white.withAlphaComponent(0.7)
            )
        )
        let timePicker = TVOSPickerView(style: timePickerStyle, delegate: timePickerDelegate)
        self.timePicker = timePicker

        let timePickerStack = UIStackView(arrangedSubviews: [timePickerLabel, timePicker])
        timePickerStack.axis = .vertical
        timePickerStack.alignment = .fill
        timePickerStack.spacing = 80
        timePickerStack.distribution = .fill

        timePickerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timePickerStack)
        NSLayoutConstraint.activate([
            timePickerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePickerStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            timePickerStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75),
            timePicker.centerYAnchor.constraint(equalTo: placePicker.centerYAnchor)
        ])
    }

    private func addDatePicker() {
        let datePickerLabel = UILabel()
        datePickerLabel.font = .preferredFont(forTextStyle: .title2)
        datePickerLabel.text = "Pick a date"
        datePickerLabel.textAlignment = .center

        let datePicker = TVOSDatePickerView(delegate: .init(
            order: .dayMonthYear,
            locale: .current,
            minYear: 1950,
            initialDate: Date()
        ))

        let datePickerStack = UIStackView(arrangedSubviews: [datePickerLabel, datePicker])
        datePickerStack.axis = .vertical
        datePickerStack.alignment = .fill
        datePickerStack.spacing = 80
        datePickerStack.distribution = .fill
        datePickerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePickerStack)
        NSLayoutConstraint.activate([
            datePickerStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            datePickerStack.widthAnchor.constraint(equalToConstant: 512),
            datePicker.centerYAnchor.constraint(equalTo: timePicker.centerYAnchor),
            datePickerStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPlacePicker()
        addTimePicker()
        addDatePicker()
    }
}

