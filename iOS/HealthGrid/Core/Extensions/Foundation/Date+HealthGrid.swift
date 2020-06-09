import UIKit

extension DateFormatter {
    
    public static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Calendar.deviceCalendar.locale
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    public static var coreDataDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Calendar.deviceCalendar.locale
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }
    
    public static var exposureDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Calendar.deviceCalendar.locale
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }
    
}

extension Calendar {
    
    public static var deviceCalendar: Calendar {
        var deviceCalendar = Calendar.current
        deviceCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return deviceCalendar
    }
    
    var shorterWeekdaySymbols: [String] {
        return symbolsFor("EEEEEE")
    }

    var shorterStandaloneWeekdaySymbols: [String] {
        return symbolsFor("cccccc")
    }

    private func symbolsFor(_ format: String) -> [String] {
        let df = DateFormatter()
        df.locale = self.locale
        df.calendar = self
        df.dateFormat = format
        let weekdays = self.range(of: .weekday, in: .year, for: Date())!
        return weekdays.map {
            let date = self.nextDate(after: Date(), matching: DateComponents(weekday: $0), matchingPolicy: .strict)!
            return df.string(from: date)
        }
    }
    
}

extension Date {
    
    func lastTwoWeeks() -> [Date] {
        var dates: [Date] = []
        guard var date = Calendar.deviceCalendar.date(byAdding: .day, value: -24, to: self) else { return [] }

        while date <= Date() {
            dates.append(date)
            guard let newDate = Calendar.deviceCalendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    func lastTwoWeekDay() -> Date {
        return Calendar.deviceCalendar.date(byAdding: .day, value: -14, to: self) ?? Date()
    }
    
    var day: Int {
        let day = Calendar.deviceCalendar.component(.day, from: self)
        return day
    }
    
    static var dateToUpdateLocation: Date {
        #if DEBUG
            return Calendar.deviceCalendar.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        #else
            return Calendar.deviceCalendar.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
        #endif
    }
    
}
