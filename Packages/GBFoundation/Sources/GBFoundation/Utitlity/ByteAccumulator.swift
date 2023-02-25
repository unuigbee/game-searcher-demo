import Foundation

public struct ByteAccumulator: CustomStringConvertible {
	private var offset = 0
	private var counter = -1
	private let name: String
	private let size: Int
	private let chunkCount: Int
	private var bytes: [UInt8]
	
	public var data: Data {
		Data(bytes[0..<offset])
	}
	
	/// Creates a named byte accumulator.
	public init(name: String, size: Int) {
		self.name = name
		self.size = size
		chunkCount = max(Int(Double(size) / 20), 1)
		print("size: \(size) chunkCount: \(chunkCount)")
		bytes = [UInt8](repeating: 0, count: size)
	}
	
	/// Appends a byte to the accumulator.
	public mutating func append(_ byte: UInt8) {
		bytes[offset] = byte
		counter += 1
		offset += 1
	}
	
	/// `true` if the current batch is filled with bytes.
	public var isBatchCompleted: Bool {
		return counter >= chunkCount
	}
	
	public mutating func checkCompleted() -> Bool {
		defer { counter = 0 }
		return counter == 0
	}
	
	/// The overall progress.
	public var progress: Double {
		Double(offset) / Double(size)
	}
	
	let sizeFormatter: ByteCountFormatter = {
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useKB]
		formatter.isAdaptive = true
		return formatter
	}()
	
	public var description: String {
		"[\(name)] \(sizeFormatter.string(fromByteCount: Int64(offset))) progress: \(progress)"
	}
}
