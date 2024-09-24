//
//  Options.swift
//  InfinityScrollKit
//
//  Created by Pierre Janineh on 24/09/2024.
//

import SwiftUI

/// Instance for customizing ``InfiniteScrollView``
public struct Options<T> {
    
    /// The scroll's orientation
    let orientation: Axis.Set = .vertical
    /// Count of items to display per page
    let countPerPage: Int = 5
    /// Pagination customizations and advanced options
    let paginationOptions: PaginationOptions? = nil
    
    /// Instance for customizing scroll's pagination
    public struct PaginationOptions {
        /// Callback for indicating when the scroll is loading new items
        let onPageLoad: (() async -> [T])? = nil
        /// Concatenation mode for loading items (comes along with `onPageLoad`
        let concatMode: ConcatMode = .manual
    }
}

extension Options {
    
    /// Enum for managing concatenation on arrays while paginating
    public enum ConcatMode {
        /// Add new items automatically to the array
        case auto
        /// Receive a new array containing all items (including new fetched items)
        case manual
    }
}
