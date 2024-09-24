//
//  OnRefresh+View.swift
//  InfinityScrollKit
//
//  Created by Pierre Janineh on 24/09/2024.
//

import SwiftUI

extension View {
    internal func onRefresh(action: @escaping @Sendable () async -> Void) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, visionOS 1.0, watchOS 8.0, *) {
            return self.refreshable(action: action)
        }
        return self
    }
}
