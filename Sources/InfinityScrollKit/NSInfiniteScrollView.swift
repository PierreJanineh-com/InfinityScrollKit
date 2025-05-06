//
//  NSInfiniteScrollView.swift
//  InfinityScrollKit
//
//  Created by Pierre Janineh on 06/05/2025.
//

#if os(macOS)
import SwiftUI
import AppKit

/// A delegate protocol for providing custom AppKit views to `NSInfiniteScrollView`.
public protocol NSInfiniteScrollViewDelegate {
	associatedtype Item: Identifiable & Equatable & Sendable
	
	/// Returns a custom cell view for the provided item at the given index.
	/// - Parameters:
	///   - item: The item to render.
	///   - at: The index path index for the item.
	func cellFor(_ item: Item, at: IndexPath.Index) -> NSView
	
	/// Provides a view shown at the end of the list (e.g., a loading spinner).
	/// Defaults to `nil`.
	///
	/// When nil is returned, or this is not implemented, a _**ProgressView**_ is displayed.
	func lastCellView() -> NSView?
	
	/// Provides a view when the array is empty (e.g., "No items yet..." label).
	/// Defaults to `nil`.
	///
	/// When nil is returned, or this is not implemented, a Label with the text _**"No items yet..."**_ is displayed.
	func emptyArrayView() -> NSView?
	
	/// Notifies when loading state changes (useful for updating UI state externally).
	/// Defaults to no-op.
	func onLoadingChanged(_ isLoading: Bool)
}
public extension NSInfiniteScrollViewDelegate {
	func lastCellView() -> NSView? { nil }
	func emptyArrayView() -> NSView? { nil }
	func onLoadingChanged(_ isLoading: Bool) { }
}

/// An AppKit-based scroll view with infinite scrolling capabilities and SwiftUI integration.
/// Wraps `InfiniteScrollView` from SwiftUI for use in AppKit.
public class NSInfiniteScrollView<
	Item: Identifiable & Equatable & Sendable,
	Delegate: NSInfiniteScrollViewDelegate
>: NSView where Delegate.Item == Item {
	
	/// Delegate responsible for providing views and handling state.
	public var delegate: Delegate?
	
	/// The current array of items.
	public private(set) var items: [Item]
	
	/// Options for configuring the scroll view behavior.
	public var options: Options<Item> {
		didSet {
			hostingController = NSHostingController(rootView: InfiniteScrollView(
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
	///   - frame: The frame of the scroll view.
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
	
	private lazy var arr: Binding<[Item]> = {
		.init(
			get: { self.items },
			set: { self.items = $0 }
		)
	}()
	
	private lazy var hostingController: NSHostingController<InfiniteScrollView<
		Item,
		NSWrapperView,
		NSWrapperView,
		NSWrapperView
	>> = {
		let view = InfiniteScrollView(
			arr: arr,
			options: options,
			onLoadingChanged: delegate?.onLoadingChanged,
			cellView: CellView,
			lastCellView: LastCellView,
			emptyArrView: EmptyArrView
		)
		return NSHostingController(rootView: view)
	}()
	
	private func setupScrollView() {
		if let old = subviews.first {
			old.removeFromSuperview()
		}
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
	
	private func CellView(_ item: Item, _ at: IndexPath.Index) -> NSWrapperView {
		guard let delegate else {
			fatalError("NSInfiniteScrollView.delegate must be assigned")
		}
		return NSWrapperView(view: delegate.cellFor(item, at: at))
	}
	
	@ViewBuilder private func LastCellView() -> NSWrapperView {
		NSWrapperView(view: delegate?.lastCellView() ?? NSEmptyView())
	}
	
	@ViewBuilder private func EmptyArrView() -> NSWrapperView {
		NSWrapperView(view: delegate?.emptyArrayView() ?? NSEmptyView())
	}
	
	deinit {
		hostingController.removeFromParent()
		hostingController.view.removeFromSuperview()
	}
}

/// A wrapper that makes a `NSView` usable inside SwiftUI.
internal struct NSWrapperView: NSViewRepresentable {
	let view: NSView
	
	func makeNSView(context: Context) -> NSView { view }
	func updateNSView(_ nsView: NSView, context: Context) {}
}

/// A default empty `NSView` used as fallback for optional views.
internal class NSEmptyView: NSView {}
#endif
