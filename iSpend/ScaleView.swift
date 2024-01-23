//
//  Scale.swift
//  iSpent
//
//  Created by Spencer Marks on 1/20/24.
//

import Foundation
import SwiftUI
import UIKit

struct ScaleView: View {
    var radioButtons: [UIButton] = []
    let numberOfButtons = 7
    @State private var showDetails = false

    var body: some View {
        HStack {
            Button("Show details") {
                showDetails.toggle()
            }

            if showDetails {
                Text("You should follow me on Twitter: @twostraws")
                    .font(.largeTitle)
            }
        }
    }
}
