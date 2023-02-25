//
//  PreviewContextMenu.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 15/06/2021.
//

import Foundation
import SwiftUI

extension View {
	func previewContextMenu(
		_ isNavigationBarHidden: Binding<Bool?>,
		colorScheme: Binding<ColorScheme>,
		disablesAnimations: Binding<Bool?> = .constant(nil)
	) -> some View {
		modifier(
			PreviewContextMenu(
				isNavigationBarHidden: isNavigationBarHidden,
				colorScheme: colorScheme,
				disablesAnimations: disablesAnimations
			)
		)
	}
}

struct PreviewContextMenu: ViewModifier {
	@AppStorage("contextMenuLocation") private var contextMenuLocation: String = "{50.0, 50.0}"
	@Environment(\.presentationMode) private var presentationMode
	
	@State private var location: CGPoint = .init(x: 50, y: 50)
	@State private var scale: Bool = false
	@State private var opacity: Double = 0.80
	@GestureState private var startLocation: CGPoint? = nil
	@Binding private var isNavigationBarHidden: Bool?
	@Binding private var colorScheme: ColorScheme
	@Binding private var disablesAnimations: Bool?
	
	init(
		isNavigationBarHidden: Binding<Bool?>,
		colorScheme: Binding<ColorScheme>,
		disablesAnimations: Binding<Bool?>
	) {
		self._isNavigationBarHidden = isNavigationBarHidden
		self._colorScheme = colorScheme
		self._disablesAnimations = disablesAnimations
	}
	
	func body(content: Content) -> some View {
		content
			.navigationBarHidden(isNavigationBarHidden ?? false)
			.overlay(contextMenu)
	}
	
	private var drag: some Gesture {
		DragGesture(minimumDistance: 0)
			.onChanged { gesture in
				var newLocation = startLocation ?? location
				newLocation.x += gesture.translation.width
				newLocation.y += gesture.translation.height
				self.location = newLocation
				self.scale = true
			}
			.updating($startLocation) { (_, startLocation, _) in
				startLocation = startLocation ?? location
			}
			.onEnded { _ in
				scale = false
			}
	}
	
	private var contextMenu: some View {
		Image(systemName: "")
			.resizable()
			.scaledToFill()
			.frame(width: 15, height: 15)
			.padding(10)
			.background(Circle().foregroundColor(.white))
			.shadow(radius: 2)
			.opacity(opacity)
			.contextMenu(menuItems: menuItems)
			.onTapGesture(count: 2) {
				presentationMode.wrappedValue.dismiss()
			}
			.scaleEffect(scale ? 2.5 : 1)
			.animation(.linear, value: scale)
			.position(x: location.x, y: location.y)
			// Stops our drag gesture conflicting with the long press
			// gesture that's applied internally within the SwiftUI contextMenu modifier.
			// Trying to long press at a finger distance greater than 0 over 0.1 seconds
			// immediately fails the long press gesture below and hence the
			// the drag gesture. This allows the long press gesture within the
			// context menu and our own gestures to be preserved/separate, including
			// the behaviours/animations that depend on it.
			.gesture(
				LongPressGesture(
					minimumDuration: 0.1,
					maximumDistance: 0
				)
				.exclusively(before: drag)
			)
			.onAppear {
				self.location = NSCoder.cgPoint(for: self.contextMenuLocation)
			}
			.onDisappear {
				self.contextMenuLocation = NSCoder.string(for: self.location)
			}
			.onChange(of: isNavigationBarHidden) { _ in
				self.opacity = 0.0
				
				withAnimation(Animation.easeInOut(duration: 1.0).delay(0.5)) {
					self.opacity = 0.80
				}
			}
	}
	
	@ViewBuilder private func menuItems() -> some View {
		if let isNavigationBarHidden = isNavigationBarHidden {
			let showOrHideText = isNavigationBarHidden ?  "Show" : "Hide"
			let showOrHideImage = isNavigationBarHidden ?  "eye.circle.fill" : "eye.slash.fill"
			
			if isNavigationBarHidden {
				Button {
					self.presentationMode.wrappedValue.dismiss()
				} label: {
					Label(
						"Back to All Previews",
						systemImage: "arrowshape.turn.up.backward.circle.fill"
					)
				}
			}
			
			Button {
				self.isNavigationBarHidden?.toggle()
			} label: {
				Label(
					"\(showOrHideText) Navigation Bar",
					systemImage: showOrHideImage
				)
			}
		}
		
		Button {
			// Add back way to change color scheme based for previews
		} label: {
			Label(
				"Toggle Appearance",
				systemImage: ""
			)
		}
		
		if let _ = disablesAnimations {
			Button {
				self.disablesAnimations?.toggle()
			} label: {
				Label(
					"\(disablesAnimations == true ?  "Enable" : "Disable") Animations",
					systemImage: disablesAnimations == true ? "sparkles" : "xmark.octagon.fill"
				)
			}
		}
	}
}
