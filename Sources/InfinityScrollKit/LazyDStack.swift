//
//  LazyDStack.swift
//  InfinityScrollKit
//
//  Created by Pierre Janineh on 24/09/2024.
//

import SwiftUI

internal struct LazyDStack<Content: View>: View {
    let orientation: Axis.Set
    let spacing: CGFloat?
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        switch orientation {
        case .horizontal:
            LazyHStack(spacing: spacing) {
                content()
            }
        default:
            LazyVStack(spacing: spacing) {
                content()
            }
        }
    }
}
