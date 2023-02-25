////
////  CarouselView.swift
////  Gamebase
////
////  Created by Emmanuel Unuigbe on 19/05/2021.
////
//
//import Foundation
//import SwiftUI
//
//class UIStateModel: ObservableObject {
//	@Published var activeCard: Int = 0
//}
//
//class CarouselConnector: ObservableObject {
//	@Published var activeItem: Int?
//	@Published var activeItemFrame: CGRect = .zero
//	
//	// TODO: - Maybe use hash values/tags to identify source
//	var updatedFromSource: Bool = false
//}
//
//
//// Carousel
//struct Carousel<Content: View>: View {
//	@ObservedObject var carouselConnector: CarouselConnector
//	@StateObject private var uiState = UIStateModel()
//	@Binding private var activeItem: Int?
//	@State private var activeItemFrame: CGRect = .zero
//	
//	private let rootCoordinateSpace = String(describing: Carousel.self)
//	private let items: [Item<Content>]
//	private let itemSpacing: CGFloat
//	private let edgeInsets: EdgeInsets
//	private let mode: Mode
//	
//	init(
//		items: [Item<Content>],
//		itemSpacing: CGFloat = 10,
//		edgeInsets: EdgeInsets = .zero,
//		activeItem: Binding<Int?> = .constant(nil),
//		mode: Mode = .draggable,
//		carouselConnector: CarouselConnector
//	) {
//		self.items = items
//		self.itemSpacing = itemSpacing
//		self.edgeInsets = edgeInsets
//		self._activeItem = activeItem
//		self.mode = mode
//		self.carouselConnector = carouselConnector
//	}
//	
//	private var drag: some Gesture {
//		DragGesture(minimumDistance: 0)
//			.onEnded { value in
//				if (value.translation.width < -50) && self.uiState.activeCard < (items.count - 1) {
//					self.uiState.activeCard = self.uiState.activeCard + 1
//					UIImpactFeedbackGenerator(style: .soft).impactOccurred()
//				} else if (value.translation.width > 50) && self.uiState.activeCard > 0 {
//					self.uiState.activeCard = self.uiState.activeCard - 1
//					UIImpactFeedbackGenerator(style: .soft).impactOccurred()
//				}
//			}
//	}
//	
//	var body: some View {
//		ScrollView(axes: .horizontal) {
//			ScrollViewReader { scrollProxy in
//				HStack(alignment: .center, spacing: itemSpacing) {
//					ForEach(items, id: \.id) { item in
//						item
//							.contentShape(Rectangle())
//							.onTapGesture {
//								uiState.activeCard = item.id
//								carouselConnector.activeItem = item.id
//							}
//							.id(item.id)
//					}
//				}
//				.padding(edgeInsets)
//				.onReceive(carouselConnector.$activeItem) { activeItem in
//					guard mode == .draggable else { return }
//					scrollTo(activeCard: activeItem, scrollProxy: scrollProxy)
//				}
//				.onChange(of: uiState.activeCard) { activeCard in
//					activeItem = activeCard
//					guard mode == .draggable else {
//						return
//					}
//					
//					withAnimation(.easeInOut) {
//						scrollTo(activeCard: activeCard, scrollProxy: scrollProxy)
//					}
//				}
//			}
//		}
//		.showsIndicators(false)
//		.contentShape(Rectangle())
//		.gesture(drag, including: mode == .draggable ? .gesture : .subviews)
//	}
//	
//	private func scrollTo(activeCard: Int?, scrollProxy: ScrollViewProxy) {
//		if activeCard == (items.count - 1) {
//			scrollProxy.scrollTo(
//				activeCard,
//				anchor: UnitPoint(
//					x: UnitPoint.trailing.x * 0.90,
//					y: UnitPoint.trailing.y
//				)
//			)
//			
//		} else {
//			scrollProxy.scrollTo(activeCard, anchor: .center)
//		}
//	}
//	
//	enum Mode {
//		case scrollable
//		case draggable
//	}
//}
//
//struct Item<Content: View>: View, Identifiable {
//	let id: Int
//	let content: Content
//	
//	init(id: Int, @ViewBuilder _ content: @escaping () -> Content) {
//		self.id = id
//		self.content = content()
//	}
//	
//	var body: some View {
//		return content
//	}
//}
//
//extension Color {
//	static var random: Color {
//		return Color(
//			red: .random(in: 0...1),
//			green: .random(in: 0...1),
//			blue: .random(in: 0...1)
//		)
//	}
//}
