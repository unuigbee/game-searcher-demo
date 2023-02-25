////
////  PagingCarousel.swift
////  Gamebase
////
////  Created by Emmanuel Unuigbe on 28/07/2021.
////
//
//import Foundation
//import SwiftUI
//
//struct PagingCarousel<Content: View>: View {
//	typealias _Item = Item<Content>
//	
//	private let items: [_Item]
//	private var animation: Animation? {
//		enableDragAnimations ? .spring() : nil
//	}
//	
//	@ObservedObject private var carouselConnector: CarouselConnector
//	@State private var preferences: [ItemGeometryData] = []
//	@State private var enableDragAnimations: Bool = false
//	@State private var lastDragValue: DragGesture.Value?
//	@StateObject private var uiState: UIStateModel = UIStateModel()
//	@Namespace private var emptyNamespace
//	
//	//  modifiers
//	var itemSpacing: CGFloat = 10
//	var padding: EdgeInsets = .zero
//	var itemAlignment: HorizontalAlignment = .leading
//	var preferredItemSize: ItemSize? = nil
//	var pageItemsNamespace: Namespace.ID?
//	var bounces: Bool = true
//	
//	init(items: [_Item], carouselConnector: CarouselConnector = .init()) {
//		self.items = items
//		self.carouselConnector = carouselConnector
//	}
//	
//	var body: some View {
//		GeometryReader { proxy in
//			Canvas { content(proxy) }
//		}
//		.frame(height: preferences.first?.bounds?.height ?? 0)
//		.padding(.top, padding.top)
//		.padding(.bottom, padding.bottom)
//		.onReceive(carouselConnector.$activeItem) { activeItem in
//			if let item = activeItem {
//				if !carouselConnector.updatedFromSource {
//					var transaction = Transaction(animation: nil)
//					transaction.disablesAnimations = true
//					
//					withTransaction(transaction) {
//						uiState.activeCard = item
//					}
//				} else {
//					DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//						uiState.activeCard = item
//					}
//				}
//			}
//		}
//	}
//	
//	private func itemSizeExperiment(_ proxy: GeometryProxy) -> ItemSize {
//		if let preferredItemSize = preferredItemSize {
//			let width = preferredItemSize.width ?? proxy.size.width
//			let height = preferredItemSize.height ?? min(proxy.size.width, proxy.size.height)
//			
//			return .init(
//				width: min(width, proxy.size.width),
//				height: height
//			)
//		}
//		
//		return .init(
//			width: proxy.size.width - (2 * leftPadding),
//			height: proxy.size.height + padding.top/2
//		)
//	}
//	
//	private func itemSize(_ proxy: GeometryProxy) -> ItemSize {
//		guard let preferredItemSize = preferredItemSize else {
//			return .init(width: proxy.size.width, height: min(proxy.size.width, proxy.size.height))
//		}
//		
//		return .init(width: preferredItemSize.width, height: preferredItemSize.height)
//	}
//	
//	private func content(_ rootProxy: GeometryProxy) -> some View {
//		GeometryReader { geometry in
//			HStack(alignment: .center, spacing: itemSpacing) {
//				ForEach(items, id: \.id) { item in
//					item
//						.matchedGeometryEffect(id: item.id, in: pageItemsNamespace ?? emptyNamespace)
//						.frame(
//							width: itemSize(rootProxy).width,
//							height: itemSize(rootProxy).height
//						)
//						.animation(animation)
//						.contentShape(Rectangle())
//						.onTapGesture {
//							carouselConnector.updatedFromSource = true
//							carouselConnector.activeItem = item.id
//							carouselConnector.activeItemFrame = preferences.first(where: { $0.id == item.id })?.bounds ?? .zero
//						}
//						.anchorPreference(
//							key: ItemGeometryPreferencesKey.self,
//							value: .bounds,
//							transform: {
//								[ItemGeometryData(id: item.id, bounds: rootProxy[$0])]
//							}
//						)
//				}
//			}
//			.offset(x: xOffset(rootProxy))
//			.contentShape(Rectangle())
//			.highPriorityGesture(drag)
//			.onPreferenceChange(ItemGeometryPreferencesKey.self) { preferences in
//				self.preferences = preferences
//			}
//		}
//		.frame(width: canvasWidth)
//	}
//	
//	private var drag: some Gesture {
//		DragGesture(minimumDistance: 15)
//			.onChanged { value in
//				self.onDragChanged(value)
//			}
//			.onEnded { value in
//				self.onDragEnded(value)
//			}
//	}
//	
//	private func onDragChanged(_ value: DragGesture.Value) {
//		let lastLocation = self.lastDragValue?.location ?? value.location
//		let swipeAngle = (value.location - lastLocation).angle ?? .zero
//		
//		guard swipeAngle.isAlongXAxis else {
//			self.lastDragValue = value
//			return
//		}
//		
//		if self.enableDragAnimations == false {
//			self.enableDragAnimations = true
//		}
//		
//		self.uiState.screenDrag = Float(value.translation.width)
//		
//		self.lastDragValue = value
//	}
//	
//	private func onDragEnded(_ value: DragGesture.Value) {
//		self.uiState.screenDrag = 0
//		
//		if (value.translation.width < -50) && self.uiState.activeCard < (self.items.count - 1) {
//			self.uiState.activeCard = self.uiState.activeCard + 1
//			UIImpactFeedbackGenerator(style: .soft).impactOccurred()
//			self.lastDragValue = nil
//		}
//		
//		if (value.translation.width > 50) && self.uiState.activeCard > 0 {
//			self.uiState.activeCard = self.uiState.activeCard - 1
//			UIImpactFeedbackGenerator(style: .soft).impactOccurred()
//			self.lastDragValue = nil
//		}
//	}
//	
//	private var leftPadding: CGFloat {
//		padding.leading
//	}
//	
//	private var rightPadding: CGFloat {
//		padding.trailing
//	}
//	
//	private var isFirstItem: Bool {
//		items.count == 1 ? false : uiState.activeCard == 0
//	}
//	
//	private var isLastItem: Bool {
//		items.count == 1 ? false : uiState.activeCard == (items.count - 1)
//	}
//	
//	private var bounceValue: Float {
//		bounces ? 4 : 2
//	}
//	
//	private var draggingOffset: Float {
//		uiState.screenDrag
//	}
//	
//	private func alignmentOffset(_ proxy: GeometryProxy) -> CGFloat {
//		let viewWidth = proxy.size.width
//		let totalMovementOfCard = totalMovement(for: uiState.activeCard)
//		let widthOfHiddenCard = viewWidth - totalMovementOfCard
//
//		var newAdjustment: CGFloat = 0
//		
//		switch itemAlignment {
//		case .leading:
//			newAdjustment = leftPadding
//		case .center:
//			newAdjustment = widthOfHiddenCard/2 + itemSpacing/2
//		case .trailing:
//			newAdjustment = widthOfHiddenCard
//		default: break
//		}
//		
//		if isFirstItem {
//			newAdjustment = leftPadding
//		} else if isLastItem {
//			newAdjustment = (widthOfHiddenCard) - (rightPadding - itemSpacing)
//		}
//		
//		return newAdjustment
//	}
//	
//	private func xOffset(_ rootProxy: GeometryProxy) -> CGFloat {
//		// offset to shift
//		let offsetToShift = xOffsetToShift(rootProxy)
//		let alignmentOffset = self.alignmentOffset(rootProxy)
//
//		let activeOffset = (offsetToShift + alignmentOffset) - (totalMovement(for: uiState.activeCard) * CGFloat(uiState.activeCard))
//		let nextOffset = (offsetToShift + alignmentOffset) - (totalMovement(for: uiState.activeCard + 1) * CGFloat(uiState.activeCard) + 1)
//		
//		var calcOffset = Float(activeOffset)
//		
//		// slow down drag at the edges of content view
//		if uiState.activeCard == 0 && draggingOffset > 0 {
//			return activeOffset + CGFloat(draggingOffset / bounceValue)
//		}
//
//		if uiState.activeCard == (items.count - 1) && draggingOffset < 0 {
//			return activeOffset + (CGFloat(draggingOffset / bounceValue))
//		}
//		
//		if calcOffset != Float(nextOffset) {
//			calcOffset = Float(activeOffset) + draggingOffset
//		}
//		
//		return CGFloat(calcOffset)
//	}
//	
//	private func totalMovement(for activeCard: Int) -> CGFloat {
//		let itemWidth = preferences.first(where: { $0.id == activeCard })?.bounds?.width ?? .zero
//		
//		return itemWidth + itemSpacing
//	}
//	
//	private func xOffsetToShift(_ proxy: GeometryProxy) -> CGFloat {
//		return (canvasWidth - proxy.size.width)/2
//	}
//	
//	private var canvasWidth: CGFloat {
//		let totalItemWidth: CGFloat = preferences
//			.compactMap { $0.bounds?.width }
//			.reduce(0, +)
//		
//		let totalSpacing = itemSpacing * CGFloat(items.count - 1)
//		
//		return totalItemWidth + totalSpacing
//	}
//	
//	class UIStateModel: ObservableObject {
//		@Published var activeCard: Int = 0
//		@Published var screenDrag: Float = 0.0
//	}
//}
//
//
//struct ItemGeometryData: Equatable, Identifiable {
//	var id: Int
//	var bounds: CGRect? = nil
//	var centerAnchor: Anchor<CGPoint>? = nil
//	var trailingAnchor: Anchor<CGPoint>? = nil
//	var leadingAnchor: Anchor<CGPoint>? = nil
//	var leading: CGPoint? = nil
//	
//	init(id: Int, bounds: CGRect) {
//		self.id = id
//		self.bounds = bounds
//	}
//	
//	static func==(lhs: ItemGeometryData, rhs: ItemGeometryData) -> Bool {
//		return lhs.id == rhs.id
//	}
//}
//
//struct ItemGeometryPreferencesKey: PreferenceKey {
//	typealias Value = [ItemGeometryData]
//
//	static var defaultValue: Value { [] }
//
//	static func reduce(
//		value: inout Value,
//		nextValue: () -> Value
//	) {
//		value.append(contentsOf: nextValue())
//	}
//}
//
//struct ItemSize {
//	var width: CGFloat?
//	var height: CGFloat?
//	
//	static let idealSize = ItemSize()
//}
