//
//  View-ExpenseStyling.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import SwiftUI

extension View {
    func style(for item: ExpenseItem) -> some View {
        return self.font(.body)
        /*
        if item.amount < 10 {
            return self.font(.body)
        } else if item.amount < 100 {
            return self.font(.title3)
        } else {
            return self.font(.title)
        }
         */
    }
}
