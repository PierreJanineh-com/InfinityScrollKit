//
//  UIInfiniteScrollView.swift
//  InfinityScrollKit
//
//  Created by Pierre Janineh on 27/09/2024.
//

#if os(macOS)


#else
import SwiftUI
import UIKit

/// A delegate protocol for providing custom UIKit views to `UIInfiniteScrollView`.
public protocol UIInfiniteScrollViewDelegate {
	associatedtype Item: Identifiable & Equatable & Sendable
	
	/// Returns a custom cell view for the provided item at the given index.
	/// - Parameters:
	///   - item: The item to render.
	///   - at: The index path index for the item.
	func cellFor(_ item: Item, at: IndexPath.Index) -> UIView
	
	/// Provides a view shown at the end of the list (e.g., a loading spinner).
	/// Defaults to `nil`.
	///
	/// When nil is returned, or this is not implemented, a _**ProgressView**_ is displayed.
	func lastCellView() -> UIView?
	
	/// Provides a view when the array is empty (e.g., "No items yet..." label).
	/// Defaults to `nil`.
	///
	/// When nil is returned, or this is not implemented, a Label with the text _**"No items yet..."**_ is displayed.
	func emptyArrayView() -> UIView?
	
	/// Notifies when loading state changes (useful for updating UI state externally).
	/// Defaults to no-op.
	func onLoadingChanged(_ isLoading: Bool)
}
public extension UIInfiniteScrollViewDelegate where Item: Identifiable & Equatable & Sendable {
	func lastCellView() -> UIView? { nil }
	func emptyArrayView() -> UIView? { nil }
	func onLoadingChanged(_ isLoading: Bool) { }
}

/// A UIKit-based scroll view with infinite scrolling capabilities and SwiftUI integration.
/// Wraps `InfiniteScrollView` from SwiftUI for use in UIKit.
public class UIInfiniteScrollView<
	Item: Identifiable & Equatable & Sendable,
	Delegate: UIInfiniteScrollViewDelegate
>: UIView where Delegate.Item == Item {
	
	/// Delegate responsible for providing views and handling state.
	public var delegate: Delegate?
	
	/// The current array of items.
	public private(set) var items: [Item]
	
	/// Options for configuring the scroll view behavior.
	public var options: Options<Item> {
		didSet {
			hostingController = .init(rootView: InfiniteScrollView(
				arr: arr,
				options: options,
				onLoadingChanged: delegate?.onLoadingChanged,
				cellView: CellView,
				lastCellView: LastCellView,
				emptyArrView: EmptyArrView
			))
			setupScrollView()
		}
	}
	
	/// Initializes the scroll view with a frame, items, and optional configuration options.
	/// - Parameters:
	///   - frame: The frame of the scroll view.
	///   - items: Initial array of items.
	///   - options: Scroll behavior configuration (default is empty).
	public init(
		items: [Item],
		options: Options<Item> = .init()
	) {
		self.items = items
		self.options = options
		
		super.init(frame: .zero)
		setupScrollView()
	}
	
	/// Convenience initializer without specifying a frame.
	/// - Parameters:
	///   - items: Initial array of items.
	///   - options: Scroll behavior configuration (default is empty).
	public init(
		frame: CGRect,
		items: [Item],
		options: Options<Item> = .init()
	) {
		self.items = items
		self.options = options
		
		super.init(frame: frame)
		setupScrollView()
	}
	
	required init?(coder: NSCoder) {
		self.items = []
		self.options = .init()
		
		super.init(coder: coder)
		setupScrollView()
	}
	
	private lazy var hostingController: UIHostingController<InfiniteScrollView<Item, UIKitWrapperView, UIKitWrapperView, UIKitWrapperView>> = {
		let infiniteScrollView = InfiniteScrollView(
			arr: arr,
			options: options,
			onLoadingChanged: delegate?.onLoadingChanged,
			cellView: CellView,
			lastCellView: LastCellView,
			emptyArrView: EmptyArrView
		)
		return .init(rootView: infiniteScrollView)
	}()
	
	private lazy var arr: Binding<[Item]> = {
		.init(
			get: {
				self.items
			},
			set: { items in
				self.items = items
			}
		)
	}()
	
	private func setupScrollView() {
		frame.size = hostingController.view.frame.size
		addSubview(hostingController.view)
		
		hostingController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			hostingController.view.topAnchor.constraint(equalTo: topAnchor),
			hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
			hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
			hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
			hostingController.view.widthAnchor.constraint(equalTo: widthAnchor)
		])
	}
	
	@ViewBuilder private func CellView(_ item: Item, _ at: IndexPath.Index) -> UIKitWrapperView {
		guard let delegate
		else {
			fatalError("`UIInfiniteScrollView.delegate` should be assigned a value")
		}
		return UIKitWrapperView(view: delegate.cellFor(item, at: at))
	}
	
	@ViewBuilder private func LastCellView() -> UIKitWrapperView {
		UIKitWrapperView(view: delegate?.lastCellView() ?? UIEmptyView())
	}
	
	@ViewBuilder private func EmptyArrView() -> UIKitWrapperView {
		UIKitWrapperView(view: delegate?.emptyArrayView() ?? UIEmptyView())
	}
}

/// A wrapper that makes a `UIView` usable inside SwiftUI.
internal struct UIKitWrapperView: UIViewRepresentable {
	let view: UIView
	
	func makeUIView(context: Context) -> UIView { view }
	
	func updateUIView(_ uiView: UIView, context: Context) {}
}

/// A default empty `UIView` used as fallback for optional views.
internal class UIEmptyView: UIView {}
#endif
