import Foundation

public extension Date {
	func toString() -> String {
		let dateStringFormatter = DateFormatter()
		 dateStringFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
		 return dateStringFormatter.string(from: self)
	}
	
	init?(_ dateString: String?) {
		guard let dateString = dateString else {
			return nil
		}
		
		let dateStringFormatter = DateFormatter()
		dateStringFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
		let d = dateStringFormatter.date(from: dateString)
		if let unwrappedDate = d {
			self.init(timeInterval:0, since:unwrappedDate)
		} else {
			self.init()
		}
	}
	
	func relativeDateWith(unitsStyle: RelativeDateTimeFormatter.UnitsStyle) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = unitsStyle
		return formatter.localizedString(for: self, relativeTo: Date())
	}

	func isInSameHour(date: Date = Date()) -> Bool {
		Calendar.current.isDate(self, equalTo: date, toGranularity: .hour)
	}

	func isInSameDay(date: Date = Date()) -> Bool {
		Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
	}

	func isInSameWeek(date: Date = Date()) -> Bool {
		Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
	}

	func isInSameMonth(date: Date = Date()) -> Bool {
		Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
	}

	func isWithinLast24Hours() -> Bool {
		Date().timeIntervalSince(self) <= 24 * 60 * 60
	}

	func relativeSingularUnitDateWith(
		unitsStyle: DateComponentsFormatter.UnitsStyle,
		allowedDateUnits: Set<Calendar.Component>
	) -> String? {
		let calendar = Calendar.current

		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = unitsStyle
		formatter.maximumUnitCount = 1
		formatter.calendar = calendar

		let interval = calendar.dateComponents(
			allowedDateUnits,
			from: self,
			to: Date()
		)

		if let year = interval.year, year > 0 {
			formatter.allowedUnits = [.year]
		} else if let month = interval.month, month > 0 {
			formatter.allowedUnits = [.month]
		} else if let week = interval.weekOfYear, week > 0 {
			formatter.allowedUnits = [.weekOfMonth]
		} else if let day = interval.day, day > 0 {
			formatter.allowedUnits = [.day]
		} else if let hour = interval.hour, hour > 0 {
			formatter.allowedUnits = [.hour]
		} else if let minute = interval.minute, minute > 0 {
			formatter.allowedUnits = [.minute]
		} else if let second = interval.second, second > 0 {
			formatter.allowedUnits = [.second]
		}

		return formatter.string(from: self, to: Date())
	}

	func minutesToNow() -> Int {
		Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
	}

	var isInToday: Bool {
		Calendar.current.isDateInToday(self)
	}

	func isInNextWeek(date: Date = Date()) -> Bool {
		let date = date
		let calendar = Calendar.current
		var components = calendar.dateComponents([.year, .month, .day], from: date)
		components.day = components.day! + 7

		guard let nextWeekDate = calendar.date(from: components) else {
			return false
		}

		return isInSameWeek(date: nextWeekDate)
	}

	static func relativeDateAsNow() -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.dateTimeStyle = .named
		return formatter.localizedString(for: Date(), relativeTo: Date())
	}
}
