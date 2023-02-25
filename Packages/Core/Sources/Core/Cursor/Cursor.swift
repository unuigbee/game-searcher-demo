import Foundation

public struct Cursor: Hashable {
	public internal(set) var totalCount: Int
	public static let `initial`: Self = .init(
		totalCount: .zero
	)
	
	var next: Int {
		let offset = totalCount == 0 ? 0 : totalCount + 1
		return max(0, offset)
	}

	func newCursor(fromPrevious cursor: Cursor, count: Int) -> Cursor {
		let newTotal = cursor.totalCount + count
		return .init(totalCount: newTotal)
	}
}
