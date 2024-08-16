//
//  ExpenseModelView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/15/24.
//

import Foundation
import SwiftUI

var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd"
    return formatter
}()
struct ExpenseModelView: View {
    var expenseModel: ExpenseModel
    
    var body: some View {
        HStack {
            Text(expenseModel.name)
            Text(dateFormatter.string(from: expenseModel.date))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            Text(expenseModel.amount, format: .localCurrency)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
        }
    }
}
