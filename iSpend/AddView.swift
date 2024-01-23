//
//  AddView.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import SwiftUI


struct AddView: View {
    @ObservedObject var expenses: Expenses
    @ObservedObject var mediations: Mediations
    
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var type = ExpenseType.Necessary
    @State private var amount = 0.0
    @State private var notes = ""
    @State private var date = Date.now
    @State private var stringAmount = "0.0"
    
    let types = [ExpenseType.Necessary, ExpenseType.Discretionary]
    @State private var sliderValue: Double = .zero
    
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
    
  
    var disableSave: Bool {
        name.isEmpty
    }
    
 
    
    var body: some View {
        let length = mediations.items.count
        var index = Int.random(in: 1..<length)
        var messageToRelectOn = mediations.items[index]

        NavigationView {
            Form {
                Text(messageToRelectOn).frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center).italic()
                
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) {
                        let label = "\($0)"
                        Text(label)
                    }
                }.onChange(of: sliderValue) { _, _ in
                    if sliderValue < 2 {
                        type = ExpenseType.Necessary
                    } else {
                        type = ExpenseType.Discretionary
                    }
                }.onChange(of: type) { _, _ in
                    if type == ExpenseType.Discretionary {
                        sliderValue = 7
                    } else {
                        sliderValue = 1
                    }
                }.onAppear(){
                    messageToRelectOn = mediations.items[index]
                      index = Int.random(in: 1..<length)

                  
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
                
                NumericTextField(numericText: $stringAmount, amountDouble: $amount)
                
                TextField("Notes", text: $notes)
                
                DatePicker(selection: $date, in: ...Date.now, displayedComponents: .date) {
                    Text("Date")
                }
                
                .navigationTitle("Record a New Expense")
                .toolbar {
                    Button("Cancel") {
                        dismiss()
                    }
                    
                    Button("Save") {
                        let item = ExpenseItem(name: name, type: type, amount: amount, note: notes, date: date)
                        expenses.items.append(item)
                        dismiss()
                    }.disabled(disableSave)
                }
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses(), mediations:Mediations())
    }
}
