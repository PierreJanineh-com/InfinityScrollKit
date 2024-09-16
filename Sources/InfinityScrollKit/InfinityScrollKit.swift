// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct InfiniteScrollView<T: Identifiable & Equatable, Cell: View>: View {
    
    let arr: Array<T>
    let options: Options
    @ViewBuilder let CellView: (T) -> Cell
    
    @State private var currentlyShown: Int = 0
    @State private var isLoading: Bool = false
    
    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(displayedItems) { item in
                    CellView(item)
                        .onAppear {
                            if item == displayedItems.last {
                                addMoreItemsIfAvailable()
                            }
                        }
                    
                    if isLoading {
                        ProgressView()
                            .padding()
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
        if currentlyShown < arr.count {
            isLoading = true
            currentlyShown += options.countPerPage
            isLoading = false
        }
    }
}

public class Options {
    
    let countPerPage: Int
    
    public init(countPerPage: Int? = nil) {
        self.countPerPage = countPerPage ?? 5
    }
}
