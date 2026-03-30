//
//  ExpenseModelView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/19/24.
//

import Foundation
import SwiftData
import SwiftUI

struct ExpenseModelView: View {
    @State var expenseModel: ExpenseModel
    var isInPeriod: Bool = true

    var body: some View {
        HStack {
            Text(expenseModel.date, format: .dateTime.month(.twoDigits).day(.twoDigits))
                .fontWeight(.regular).font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(expenseModel.name)
                .fontWeight(.regular).font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(expenseModel.category)
                .fontWeight(.regular).font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(expenseModel.amount, format: .localCurrency)
                .fontWeight(.regular).font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(isInPeriod ? 1.0 : 0.35)
    }
}
