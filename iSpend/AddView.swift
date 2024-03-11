//
//  AddView.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import SwiftUI


struct AddView: View {
    @StateObject var mediations = Mediations()

    @State var expenseItem: ExpenseItem
    
    @ObservedObject var expenses: Expenses
    @Environment(\.dismiss) var dismiss
    @State var stringAmount:String = ""

    /*
    @State   var name = expenseItem.name
    @State   var type = expenseItem.type
    @State   var amount = expenseItem.amount
    @State   var notes = expenseItem.note
    @State   var date = expenseItem.date
     */
    
    
   
    
    let types = [ExpenseType.Necessary, ExpenseType.Discretionary]
    @State private var sliderValue: Double = .zero
    
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
    
    var disableSave: Bool {
        expenseItem.name.isEmpty
    }
    
    var messageToRelectOn:String {
        let index = Int.random(in: 1..<mediations.items.count)
        return  mediations.items[index]
    }
  
    var body: some View {

        NavigationView {
            Form {
               
                Text(messageToRelectOn).frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center).italic()
                
                TextField("Name", text: $expenseItem.name)
                
                Picker("Type", selection: $expenseItem.type) {
                    ForEach(types, id: \.self) {
                        let label = "\($0)"
                        Text(label)
                    }
                }.onChange(of: sliderValue) { _, _ in
                    if sliderValue < 2 {
                        expenseItem.type = ExpenseType.Necessary
                    } else {
                        expenseItem.type = ExpenseType.Discretionary
                    }
                }.onChange(of: expenseItem.type) { _, _ in
                    if expenseItem.type == ExpenseType.Discretionary {
                        sliderValue = 7
                    } else {
                        sliderValue = 1
                    }
                }
                
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(Slider(value: $sliderValue, in: 1 ... 7, step: 1))
                    
                    // Dummy replicated slider, to allow sliding
                    Slider(value: $sliderValue, in: 1 ... 7, step: 1)
                        .opacity(0.05) // Opacity is the trick here.
                }
                NumericTextField(numericText: $stringAmount, amountDouble: $expenseItem.amount)
                
                TextField("Notes", text: $expenseItem.note)
                
                DatePicker(selection: $expenseItem.date, in: ...Date.now, displayedComponents: .date) {
                    Text("Date")
                }
                
                .navigationTitle("Record a New Expense")
                .toolbar {
                    Button("Cancel") {
                        dismiss()
                    }
                    
                    Button("Save") {
                        if let index = expenses.allItems.firstIndex(where: { $0.id == expenseItem.id }) {
                            expenses.allItems.remove(at: index)
                        }
                        expenses.allItems.append(expenseItem)
                        expenses.loadData()
                        dismiss()
                        
                    }.disabled(disableSave)
                }
            }
        }
    }
}
 
