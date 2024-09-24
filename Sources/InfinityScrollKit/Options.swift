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
        /// Concatenation mode for loading items (comes along with `onPageLoad`
        let concatMode: ConcatMode
        /// Callback for indicating when the scroll is loading new items
        let onPageLoad: (() async -> [T])?
        /// Callback for refreshing the array (available for iOS 15+, macCatalyst 15+, macOS 12+, tvOS 15+, visionOS 1+, watchOS 8+)
        let onRefresh: (() async -> [T])?
        
        /**
         Creates an instance to customize scroll pagination.
         - Parameters:
            - concatMode: The preferred mode for handling array pagination.
            - onPageLoad: The callback action for handling next page loading.
         */
        public init(concatMode: ConcatMode = .manual,
                    onPageLoad: (() async -> [T])? = nil) {
            self.concatMode = concatMode
            self.onPageLoad = onPageLoad
            self.onRefresh = nil
        }
        
        /**
         Creates an instance to customize scroll pagination.
         - Parameters:
            - concatMode: The preferred mode for handling array pagination.
            - onPageLoad: The callback action for handling next page loading.
            - onRefresh: A callback to handle scroll refresh.
         */
        @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, visionOS 1.0, watchOS 8.0, *)
        public init(concatMode: ConcatMode = .manual,
                    onPageLoad: (() async -> [T])? = nil,
                    onRefresh: (() async -> [T])? = nil) {
            self.concatMode = concatMode
            self.onPageLoad = onPageLoad
            self.onRefresh = onRefresh
        }
    }
}
