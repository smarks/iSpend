//
//  ContentView.swift
//   
//
//  Created by Spencer Marks on 5/7/24.
//

import SwiftData
import SwiftUI
struct ContentView: View {
   
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
     
    @Query(filter: #Predicate<ExpenseModel>{ expense in expense.type.rawValue == ExpenseType.Discretionary.rawValue }, sort:[SortDescriptor(\ExpenseModel.date)])
    private var discretionaryExpenses: [ExpenseModel]

   // @Query(filter: #Predicate<ExpenseModel>{ expense in expense.type == ExpenseType.Necessary }, sort:[SortDescriptor(\ExpenseModel.date)])
    private var necessaryExpenses: [ExpenseModel]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(discretionaryExpenses, id: \.id) { item in
                    ExpenseModelView(expenseModel: item)
                }
                
            }.navigationTitle("Discretionary Expenses")
            
           
        }
    }
}
