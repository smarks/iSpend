//
//  ExpenseModelView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/19/24.
//

import Foundation
import SwiftUI

struct ExpenseModelView: View {
    @State var expenseModel: ExpenseModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack {
            Text(expenseModel.name)
            Text(dateFormatter.string(from: expenseModel.date))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(expenseModel.amount, format: .localCurrency)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
