//
//  LastCellView.swift
//  InfinityScrollKit
//
//  Created by Pierre Janineh on 24/09/2024.
//

import SwiftUI

struct LastCellView<LastCell: View>: View {
    @ViewBuilder let lastCellView: () -> LastCell
    
    var body: some View {
		if lastCellView is () -> EmptyView ||
			(lastCellView() as? KitWrapperView)?.view is KitEmptyView {
            ProgressView()
                .padding()
        } else {
            lastCellView()
        }
    }
}
