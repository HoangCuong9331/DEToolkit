//
//  Date.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//
import Foundation

public extension Date {
    /// Creates a date from a string with a specified format.
    /// - Parameters:
    ///   - inputFormat: The date format (e.g., "yyyy-MM-dd HH:mm:ss")
    ///   - string: The date string to parse
    init?(inputFormat: String, string: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale.init(identifier: "en_US")
        if let date = dateFormatter.date(from: string) {
            self.init(timeInterval: 0, since: date)
        } else {
            return nil
        }
    }
    
    /// Returns a new Date by adding or subtracting the specified number of days from the current date.
    ///
    /// - Parameter addingDay: The number of days to add. Use negative values to subtract days.
    /// - Returns: A new Date object offset by the specified number of days, or nil if the calculation fails.
    ///
    /// - Example:
    /// ```swift
    /// let today = Date()
    /// let tomorrow = today.date(by: 1)         // Adds 1 day
    /// let yesterday = today.date(by: -1)       // Subtracts 1 day
    /// let nextWeek = today.date(by: 7)         // Adds 7 days
    /// ```
    func date(by addingDay: Int) -> Date? {
        var dayComponent    = DateComponents()
        dayComponent.day    = addingDay
        let theCalendar     = Calendar.current
        let result          = theCalendar.date(byAdding: dayComponent, to: self)
        return result
    }
}
