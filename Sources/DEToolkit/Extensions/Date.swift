//
//  Date.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//
import Foundation

public extension Date {
    init?(inputFormat: String, string: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale.init(identifier: "en_US")
        if let date = dateFormatter.date(from: string) {
            self.init(timeInterval: .leastNonzeroMagnitude, since: date)
        } else {
            return nil
        }
    }
    
    func date(by addingDay: Int) -> Date? {
        var dayComponent    = DateComponents()
        dayComponent.day    = addingDay
        let theCalendar     = Calendar.current
        let result          = theCalendar.date(byAdding: dayComponent, to: self)
        return result
    }
}
