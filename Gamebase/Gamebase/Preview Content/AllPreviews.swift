////
////  AllPreviews.swift
////  Gamebase
////
////  Created by Emmanuel Unuigbe on 09/06/2021.
////
//
//import Foundation
//import SwiftUI
//
//struct AllPreviews: View {
//	private typealias SectionTitleKey = String
//	
//	@StateObject var appDriver = AppDriver()
//	// id state property for destroying/refreshing the state of our content/detail views whenever
//	// we navigate back to the root view.
//	// This stops our content views from holding on to any bad/stale state
//	// that could cause crashes on the main thread.
//	@State private var id: UUID = UUID()
//	@State private var isNavigationBarHidden: Bool? = true
//	@State private var colorScheme: ColorScheme = .light
//	@State private var disablesAnimations: Bool? = false
//	
//	@Environment(\.presentationMode) var presentationMode
//	
//	// We type erase the type of content view we want to render
//	// and only expose the preview and display-name.
//	// this allows us to build a list view of preview configurations
//	// of the same type but with different content: AnyPreviewConfiguration<AnyView>
//	private var gameDetailPreviews: [AnyPreviewConfiguration<AnyView>] {
//		return GameDetailView_Previews
//			.configurations
//			.eraseToAnyConfigurations
//	}
//	
//	private var gameListPreviews: [AnyPreviewConfiguration<AnyView>] {
//		return GameListView_Previews
//			.configurations
//			.eraseToAnyConfigurations
//	}
//	
//	private var searchPreviews: [AnyPreviewConfiguration<AnyView>] {
//		return SearchView_Previews
//			.configurations
//			.eraseToAnyConfigurations
//	}
//	
//	private var fullscreenCarousel:  [AnyPreviewConfiguration<AnyView>] {
//		return FullScreenCarousel_Previews
//			.configurations
//			.eraseToAnyConfigurations
//	}
//	
//	// Behaves like an ordered dictionary - This allows the list view to retain its row/item
//	// order even after we destroy its children views i.e. section items views
//	private var keyedConfigurations: KeyValuePairs<SectionTitleKey, [AnyPreviewConfiguration<AnyView>]> {
//		return [
//			"Game List": gameListPreviews,
//			"Game Detail": gameDetailPreviews,
//			"Search": searchPreviews,
//			"Fullscreen Carousel": fullscreenCarousel
//		]
//	}
//	
//	var body: some View {
//		GeometryReader { proxy in
//			NavigationView {
//				List {
//					ForEach(keyedConfigurations.elements, id: \.key) { keyedConfiguration in
//						Section(header: Text(keyedConfiguration.key)) {
//							ForEach(keyedConfiguration.configurations) { config in
//								NavigationLink(
//									config.displayName,
//									destination: preview(
//										config.preview,
//										insets: proxy.safeAreaInsets
//									)
//								)
//							}
//							.id(id)
//						}
//					}
//				}
//				.listStyle(SidebarListStyle())
//				.navigationTitle("All Previews")
//				.navigationBarTitleDisplayMode(.inline)
//				.previewContextMenu(
//					.constant(nil),
//					colorScheme: $colorScheme,
//					disablesAnimations: $disablesAnimations
//				)
//				.preferredColorScheme(colorScheme)
//			}
//		}
//		.onChange(of: id) { _ in
//			reset()
//		}
//	}
//	
//	private func reset() {
//		mockSingletonsStore.removeAll()
//	}
//	
//	private func preview(_ view: AnyView, insets: EdgeInsets) -> some View {
//		view
//			.previewContextMenu(
//				$isNavigationBarHidden,
//				colorScheme: $colorScheme
//			)
//			.configureEnvironment(appDriver, insets)
//			.transaction { transaction in
//				guard let disableAnimations = disablesAnimations else { return }
//				if disableAnimations {
//					transaction.animation = nil
//				}
//				transaction.disablesAnimations = disableAnimations
//			}
//			.onDisappear {
//				DispatchQueue.main.async {
//					id = UUID()
//				}
//			}
//	}
//}
//
//private extension View {
//	func configureEnvironment(
//		_ appDriver: AppDriver,
//		_ insets: EdgeInsets
//	) -> some View {
//		environmentObject(appDriver)
//			.environmentObject(appDriver.engine)
//			.environmentObject(appDriver.state.hud)
//			.environmentObject(appDriver.state.service)
//			.environmentObject(GBSceneDelegate())
//			.environment(\.preferredContextMenuSystemImage, "text.justify")
//			.environment(\.ignoredContainerEdgeInsets, insets)
//			.environmentObject(FirstResponderSetter())
//	}
//}
//
//struct All_Previews: PreviewProvider {
//	static var configuredPreviews: some View {
//		AllPreviews()
//	}
//	
//	static var previews: some View {
//		Group {
//			configuredPreviews
//				.previewDevice(.init(rawValue: PreviewDevice.iPhoneX))
//				.previewDisplayName("\(PreviewDevice.iPhoneX)")
//			configuredPreviews
//				.previewDevice(.init(rawValue: PreviewDevice.iPhone11))
//				.previewDisplayName("\(PreviewDevice.iPhone11)")
//			configuredPreviews
//				.previewDevice(.init(rawValue: PreviewDevice.iPhoneSE))
//				.previewDisplayName("\(PreviewDevice.iPhoneSE)")
//		}
//	}
//}
