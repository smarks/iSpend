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
            
            Text(dateFormatter.string(from: expenseModel.date))
                .fontWeight(.regular).font(.caption) //.system(size: 16))
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
    }
}
