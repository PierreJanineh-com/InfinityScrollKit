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
    let orientation: Axis.Set
    /// Count of items to display per page
    let countPerPage: Int
    /// Pagination customizations and advanced options
    let paginationOptions: PaginationOptions?
    
    /**
     Options initializer for customizing count of items per page.
     - Parameters:
        - orientation: The orientation of the scroll.
        - countPerPage: Number of items in a single page (default value is 5).
        - paginationOptions: An instance for advanced pagination options.
     */
    public init(orientation: Axis.Set = .vertical,
                countPerPage: Int = 5,
                paginationOptions: PaginationOptions? = nil) {
        self.orientation = orientation
        self.countPerPage = countPerPage
        self.paginationOptions = paginationOptions
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

extension Options {
    
    /// Instance for customizing scroll's pagination
    public struct PaginationOptions {
        /// Callback for indicating when the scroll is loading new items
        let onPageLoad: (() async -> [T])?
        /// Concatenation mode for loading items (comes along with `onPageLoad`
        let concatMode: ConcatMode
        
        /**
         Creates an instance to customize scroll pagination
         */
        public init(onPageLoad: (() async -> [T])? = nil,
             concatMode: ConcatMode = .manual) {
            self.onPageLoad = onPageLoad
            self.concatMode = concatMode
        }
    }
}
