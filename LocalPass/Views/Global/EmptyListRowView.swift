//
//  EmptyListRowView.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import SwiftUI

struct EmptyListRowView: View {
    var body: some View {
        Spacer()
            .listRowSeparator(.hidden)
            .moveDisabled(true)
    }
}

struct EmptyListRowView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListRowView()
    }
}
