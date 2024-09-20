// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct InfiniteScrollView<
    T: Identifiable & Equatable,
    Cell: View,
    LastCell: View
>: View {
    
    @State private var currentlyShown: Int = 0
    @Binding private var isLoading: Bool
    
    @State private var arr: Array<T>
    private let options: Options<T>
    @ViewBuilder private let cellView: (T) -> Cell
    @ViewBuilder private let lastCellView: (() -> LastCell)?
    
    /**
     Creates an infinite scroll view.
     - Parameters:
        - arr: The array of items to display.
        - options: An instance of an `Options` to customize the scroll view.
        - cellView: A `ViewBuilder` function that returns the cell view for every item.
        - lastCellView: A `ViewBuilder` function that returns the last cell. Thsi is used for displaying errors and progress.
     */
    public init(arr: Array<T>,
                isLoading: Binding<Bool>? = nil,
                options: Options<T>? = nil,
                cellView: @escaping (T) -> Cell,
                lastCellView: (() -> LastCell)? = nil) {
        self._arr = .init(initialValue: arr)
        self._isLoading = isLoading ?? State(initialValue: false).projectedValue
        self.options = options ?? .init()
        self.cellView = cellView
        self.lastCellView = lastCellView
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(displayedItems) { item in
                    cellView(item)
                        .onAppear {
                            if item == displayedItems.last {
                                addMoreItemsIfAvailable()
                            }
                        }
                    
                    if isLoading {
                        if let lastCellView {
                            lastCellView()
                        } else {
                            ProgressView()
                                .padding()
                        }
                    }
                }
            }
        }
    }
    
    private var displayedItems: Array<T>.SubSequence {
        let range = 0...currentlyShown
        let safeRange = range.clamped(to: 0...arr.count-1)
        return arr[safeRange]
    }
    
    private func addMoreItemsIfAvailable() {
        isLoading = true
        
        if currentlyShown < arr.count {
            currentlyShown += options.countPerPage
        } else if let onPageLoad = options.onPageLoad,
                  let retrievesFullArray = options.retrievesFullArray {
            if retrievesFullArray {
                self.arr = onPageLoad()
            } else {
                self.arr += onPageLoad()
            }
        }
        
        isLoading = false
    }
}

public class Options<T> {
    
    let countPerPage: Int
    let onPageLoad: (() -> [T])?
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
    public init(countPerPage: Int? = nil, onPageLoad: @escaping () -> [T], retrievesFullArray: Bool) {
        self.countPerPage = countPerPage ?? 5
        self.onPageLoad = onPageLoad
        self.retrievesFullArray = retrievesFullArray
    }
}
