// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct InfiniteScrollView<
    T: Identifiable & Equatable,
    Cell: View,
    LastCell: View,
    EmptyArrView: View
>: View {
    
    @State private var currentlyShown: Int = 0
    @State private var privateIsLoading: Bool = false
    private var isLoading: Binding<Bool>? = nil
    
    @State private var arr: Array<T>
    private let options: Options<T>
    @ViewBuilder private let cellView: (T) -> Cell
    @ViewBuilder private let lastCellView: () -> LastCell
    @ViewBuilder private let emptyArrView: () -> EmptyArrView
    
    /**
     Creates an infinite scroll view.
     - Parameters:
        - arr: The array of items to display.
        - isLoading: The state of the scroll.
        - options: An instance of an `Options` to customize the scroll view.
        - cellView: A `ViewBuilder` function that returns the cell view for every item.
        - lastCellView: A `ViewBuilder` function that returns the last cell. Thsi is used for displaying errors and progress.
        - emptyArrView: The view to use when `arr` is empty.
     */
    public init(arr: Array<T>,
                isLoading: Binding<Bool>? = nil,
                options: Options<T>? = nil,
                cellView: @escaping (T) -> Cell,
                lastCellView: @escaping () -> LastCell = { EmptyView() },
                emptyArrView: @escaping () -> EmptyArrView = { EmptyView() }) {
        self._arr = .init(initialValue: arr)
        self.isLoading = isLoading ?? .init(get: { self.privateIsLoading },
                                            set: { _ in })
        self.options = options ?? .init()
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
                
                if let isLoading, isLoading.wrappedValue {
                    if lastCellView is () -> EmptyView {
                        ProgressView()
                            .padding()
                    } else {
                        lastCellView()
                    }
                }
            }
        }
    }
    
    private var displayedItems: Array<T>.SubSequence {
        guard !arr.isEmpty else { return [] }
        
        let range = 0...currentlyShown
        let safeRange = range.clamped(to: 0...arr.count-1)
        return arr[safeRange]
    }
    
    private func addMoreItemsIfAvailable() async {
        isLoading?.wrappedValue = true
        
        if currentlyShown < arr.count {
            currentlyShown += options.countPerPage
        }
        
        if let onPageLoad = options.onPageLoad,
                  let retrievesFullArray = options.retrievesFullArray {
            if retrievesFullArray {
                await self.arr = onPageLoad()
            } else {
                await self.arr += onPageLoad()
            }
        }
        
        isLoading?.wrappedValue = false
    }
}

public class Options<T> {
    
    let countPerPage: Int
    let onPageLoad: (() async -> [T])?
    let retrievesFullArray: Bool?
    
    /**
     Options initializer for customizing count of items per page.
     - Parameters:
        - countPerPage: Number of items in a single page (default value is 5).
     */
    public init(countPerPage: Int? = nil) {
        self.countPerPage = countPerPage ?? 5
        self.onPageLoad = nil
        self.retrievesFullArray = nil
    }
    
    /**
     Options initializer for custom inifinite loading.
     - Parameters:
        - countPerPage: Number of items in a single page (default value is 5).
        - onPageLoad: The callback function that retrieves an array to add to or replace the current array. This is typically the callback that handles scrolling down to the end.
        - retrievesFullArray: A boolean to indicate whether to add to or replace current array with the `onPageLoad` return value.
     */
    public init(countPerPage: Int? = nil, onPageLoad: @escaping () async -> [T], retrievesFullArray: Bool) {
        self.countPerPage = countPerPage ?? 5
        self.onPageLoad = onPageLoad
        self.retrievesFullArray = retrievesFullArray
    }
}
