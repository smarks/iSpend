//
//  Budgets.swift
//  iSpend
//
//  Created by Spencer Marks on 3/2/24.
//

import Foundation

//

class Budgets: ObservableObject {
    @Published var allItems = [BudgetItem]() {
        didSet {
            
            if let encoded = try? JSONEncoder().encode(allItems) {
                UserDefaults.standard.set(encoded, forKey: "Budgets")
            }
        }
    }

    var discretionaryBudget: Double {
        get{
            let discrtonaryItems =  (allItems.filter { $0.type == BudgetType.Discretionary })
            if discrtonaryItems.isEmpty {
                return 0
            } else {
                return discrtonaryItems[0].amount
            }
        }
        set(value) {            
            let discrtonaryItems =   (allItems.filter { $0.type == BudgetType.Discretionary })
            if discrtonaryItems.isEmpty{
                allItems.append(BudgetItem(name:"Discretionary", type: BudgetType.Discretionary, amount: 0))
            } else {
                var budgetItem = (allItems.filter { $0.type == BudgetType.Discretionary })[0]
                budgetItem.amount = value
            }
            
        }
    }
    var necessaryBudget: Double {
        get {
            let necessaryItems =   (allItems.filter { $0.type == BudgetType.Necessary })
            if necessaryItems.isEmpty{
                print("Get nothing")
                print(0)
                return 0
            }else {
                print("")
                print(necessaryItems[0].amount)
                return necessaryItems[0].amount
                
            }
            
        }
        set(value) {
            print("set")
            print(value)
            let necessaryItems =   (allItems.filter { $0.type == BudgetType.Necessary })
            if necessaryItems.isEmpty{
                print("empty")
                allItems.append(BudgetItem(name:"Necessary", type: BudgetType.Necessary, amount: 0))
            } else {
                print("adjust")
                var budgetItem = (allItems.filter { $0.type == BudgetType.Necessary })[0]
                budgetItem.amount = value
            }
            print("budget")
            print(necessaryBudget)
        }
    }

    init() {
      loadData()
    }
    
    func loadData() {
        if let savedItems = UserDefaults.standard.data(forKey: "Budgets") {
            if let decodedItems = try? JSONDecoder().decode([BudgetItem].self, from: savedItems) {
                allItems = decodedItems
                return
            }
        }

        allItems = []
    }
}
