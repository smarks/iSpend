//
//  ExpenseSection.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import SwiftUI

struct ExpenseSection: View {
    let title: String
    let expenses: [ExpenseItem]
    
    let deleteItems: (IndexSet) -> Void
    let editItems: () -> Void
    
    let budget:Double
    
    
    var total: Double {
        var t: Double = 0.0
        for item in expenses {
            t = t + item.amount
        }
        return t
    }
    
    var color: Color {
        if budget >= total {
            return Color.blue
        } else {
            return Color.red
        }
    }
    
    var body: some View {
        //   NavigationStack {
        Section(title) {
            HStack {
                Text("Budget:").font(.headline)
                
                Text(budget, format: .localCurrency)
                
            }
            
            HStack {
                Text("Total: ").font(.headline)
                Text(total, format: .localCurrency).foregroundColor(color)
            }
            
            ForEach(expenses) {
                item in

                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                    }
                }
            }
        //    .onDelete(perform: deleteItems)
            .onTapGesture(perform: editItems)

            // section
        }

        // view
    }
}
