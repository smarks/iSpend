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

    private var priorityColor: Color {
        switch expenseModel.discretionaryValue {
        case 1:     return .green
        case 2:     return Color(red: 0.6, green: 0.8, blue: 0.2)   // lime
        case 3:     return .yellow
        case 4:     return .orange
        case 5:     return Color(red: 0.95, green: 0.5, blue: 0.2)  // dark orange
        case 6:     return Color(red: 0.95, green: 0.35, blue: 0.3) // warm red
        default:    return .red
        }
    }

    var body: some View {
        HStack {
            Circle()
                .fill(priorityColor)
                .frame(width: 7, height: 7)

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
