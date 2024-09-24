//
//  EmptyArrayView.swift
//  InfinityScrollKit
//
//  Created by Pierre Janineh on 24/09/2024.
//

import SwiftUI

struct EmptyArrayView<EmptyArrView: View>: View {
    @ViewBuilder let emptyArrView: () -> EmptyArrView
    
    var body: some View {
        Group {
            if emptyArrView is () -> EmptyView {
                Text("No items yet...")
            } else {
                emptyArrView()
            }
        }
    }
}
