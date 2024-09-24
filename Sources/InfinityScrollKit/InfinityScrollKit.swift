// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

/// A view that displays a paginated array in an infinity scroll.
public struct InfiniteScrollView<
    T: Identifiable & Equatable & Sendable,
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
        ScrollView(options.orientation) {
            LazyVStack(spacing: options.spacing) {
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
        .onChange(of: isLoading) {
            onLoadingChanged?(isLoading)
        }
        .onRefresh {
            if let refreshed = await options.paginationOptions?.onRefresh?() {
                await updateArr(refreshed)
            } else if let _ = options.paginationOptions?.onRefresh {
                await updateArr()
            }
        }
    }
    
    private func updateArr(_ newItems: [T] = []) {
        Task { @MainActor in
            self.arr = newItems
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
        
        if let paginationOptions = options.paginationOptions,
           let onPageLoad = paginationOptions.onPageLoad {
            if paginationOptions.concatMode == .manual {
                await updateArr(onPageLoad())
            } else {
                await updateArr(arr + onPageLoad())
            }
        }
        
        isLoading = false
    }
}
