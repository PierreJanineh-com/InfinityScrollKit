// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

/// A view that displays a paginated array in an infinity scroll.
public struct InfiniteScrollView<
    T: Identifiable & Equatable,
    Cell: View,
    LastCell: View,
    EmptyArrView: View
>: View {
    
    @State private var currentlyShown: Int = 0
    @State private var isLoading: Bool = false
    
    @State private var arr: Array<T>
    private let options: Options<T>
    private let onLoadingChanged: ((Bool) -> Void)?
    @ViewBuilder private let cellView: (T) -> Cell
    @ViewBuilder private let lastCellView: () -> LastCell
    @ViewBuilder private let emptyArrView: () -> EmptyArrView
    
    /**
     Creates an infinite scroll view.
     - Parameters:
        - arr: The array of items to display.
        - options: An instance of an `Options` to customize the scroll view.
        - onLoadingChanged: A callback function to get updates of state of the scroll.
        - cellView: A `ViewBuilder` function that returns the cell view for every item.
        - lastCellView: A `ViewBuilder` function that returns the last cell. Thsi is used for displaying errors and progress.
        - emptyArrView: The view to use when `arr` is empty.
     */
    public init(arr: Array<T>,
                options: Options<T>? = nil,
                onLoadingChanged: ((Bool) -> Void)? = nil,
                cellView: @escaping (T) -> Cell,
                lastCellView: @escaping () -> LastCell = { EmptyView() },
                emptyArrView: @escaping () -> EmptyArrView = { EmptyView() }) {
        self._arr = .init(initialValue: arr)
        self.options = options ?? .init()
        self.onLoadingChanged = onLoadingChanged
        self.cellView = cellView
        self.lastCellView = lastCellView
        self.emptyArrView = emptyArrView
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(displayedItems) { item in
                    cellView(item)
                        .onAppear {
                            if item == displayedItems.last {
                                Task {
                                    await addMoreItemsIfAvailable()
                                }
                            }
                        }
                }
                
                if arr.isEmpty {
                    Group {
                        if emptyArrView is () -> EmptyView {
                            Text("No items yet...")
                        } else {
                            emptyArrView()
                        }
                    }
                    .onAppear {
                        Task {
                            await addMoreItemsIfAvailable()
                        }
                    }
                }
                
                if isLoading {
                    if lastCellView is () -> EmptyView {
                        ProgressView()
                            .padding()
                    } else {
                        lastCellView()
                    }
                }
            }
        }
        .onChange(of: isLoading) { _ in
            onLoadingChanged?(isLoading)
        }
    }
    
    private var displayedItems: Array<T>.SubSequence {
        guard !arr.isEmpty else { return [] }
        
        let range = 0...currentlyShown
        let safeRange = range.clamped(to: 0...arr.count-1)
        return arr[safeRange]
    }
    
    private func addMoreItemsIfAvailable() async {
        isLoading = true
        
        if currentlyShown < arr.count {
            currentlyShown += options.countPerPage
        }
        
        if let onPageLoad = options.onPageLoad,
           let concatMode = options.concatMode {
            if concatMode == .manual {
                await self.arr = onPageLoad()
            } else {
                await self.arr += onPageLoad()
            }
        }
        
        isLoading = false
    }
}

/**
 Instance for customizing ``InfiniteScrollView``
 */
public class Options<T> {
    
    /// Count of items to display per page
    let countPerPage: Int
    /// Callback for indicating when the scroll is loading new items
    let onPageLoad: (() async -> [T])?
    /// Concatenation mode for loading items (comes along with `onPageLoad`
    let concatMode: ConcatMode?
    
    /**
     Options initializer for customizing count of items per page.
     - Parameters:
        - countPerPage: Number of items in a single page (default value is 5).
     */
    public init(countPerPage: Int? = nil) {
        self.countPerPage = countPerPage ?? 5
        self.onPageLoad = nil
        self.concatMode = nil
    }
    
    /**
     Options initializer for custom inifinite loading.
     - Parameters:
        - countPerPage: Number of items in a single page (default value is 5).
        - onPageLoad: The callback function that retrieves an array to add to or replace the current array. This is typically the callback that handles scrolling down to the end.
        - concatMode: An enum to indicate whether to add to or replace current array with the `onPageLoad` return value.
     */
    public init(countPerPage: Int? = nil, onPageLoad: @escaping () async -> [T], concatMode: ConcatMode = .auto) {
        self.countPerPage = countPerPage ?? 5
        self.onPageLoad = onPageLoad
        self.concatMode = concatMode
    }
    
    /**
     Enum for managing concatenation on arrays while paginating
     */
    public enum ConcatMode {
        /// Add new items automatically to the array
        case auto
        /// Receive a new array containing all items (including new fetched items)
        case manual
    }
}
