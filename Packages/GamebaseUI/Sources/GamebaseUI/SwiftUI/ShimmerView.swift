import SwiftUI

public struct ShimmerView: View {
	public struct Config {
		let duration: Double
		let minOpacity: Double
		let maxOpacity: Double
		let cornerRadius: CGFloat
		
		public static let `default`: Config = .init(
			duration: 0.9,
			minOpacity: 0.25,
			maxOpacity: 1.0,
			cornerRadius: 5.0
		)
		
		public init(
			duration: Double = 0.9,
			minOpacity: Double = 0.25,
			maxOpacity: Double = 1.0,
			cornerRadius: CGFloat = 5.0
		) {
			self.duration = duration
			self.minOpacity = minOpacity
			self.maxOpacity = maxOpacity
			self.cornerRadius = cornerRadius
		}
	}
	
	private let config: Config
	
	@State private var opacity: Double = 0.25
	
	public init(config: Config = .default) {
		self.config = config
		self.opacity = config.minOpacity
	}
	
	public var body: some View {
		RoundedRectangle(cornerRadius: config.cornerRadius)
			.fill(Color.gray)
			.opacity(opacity)
			.onAppear {
				let baseAnimation = Animation.easeInOut(duration: config.duration)
				let repeated = baseAnimation.repeatForever(autoreverses: true)
				
				DispatchQueue.main.async {
					withAnimation(repeated) {
						self.opacity = config.maxOpacity
					}
				}
			}
	}
}
