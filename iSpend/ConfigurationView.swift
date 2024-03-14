//
//  ConfigurationView.swift
//  iSpend
//
//  Created by Spencer Marks on 3/13/24.
//

import Combine
import Foundation
import SwiftUI

enum ConfigurationTypes: String, CaseIterable, Hashable {
    case mediations = "Mediations"
    case categories = "Categories"
}

struct ConfigurationView: View {
    @State var isPresentingConfirm: Bool = false
    @State private var showAlert = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var categories: Categories
    @ObservedObject var mediations: Mediations

    var body: some View {
        Text("Categories")
        EditListView(items: $categories.items)
        Text("Mediations")
        EditListView(items: $mediations.items)
    }
}
