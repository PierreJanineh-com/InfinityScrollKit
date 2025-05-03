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
		if emptyArrView is () -> EmptyView ||
			(emptyArrView() as? UIKitWrapperView)?.view is UIEmptyView {
			Text("No items yet...")
		} else {
			emptyArrView()
		}
    }
}
