//
//  ListItem.swift
//  OutbrainSwiftUI
//
//  Created by Mikhail Vasilev on 22.07.24.
//

import SwiftUI

struct ListItem: View {

    var color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
    }
}
