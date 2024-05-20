//
//  Budgets.swift
//  iSpend
//
//  Created by Spencer Marks on 3/2/24.
//

import Foundation
import SwiftUI

class Budget: ObservableObject {
    var amount: String {
        get { "0.0" }
        set { }
    }

    var label: String { "Undefined" }
}

class DiscretionaryBudget: Budget {
    @AppStorage("discretionaryBudget") var amountLocal: String = "0.0"

    override var amount: String {
        get { amountLocal }
        set {
            amountLocal = newValue
            objectWillChange.send()
        }
    }

    override var label: String { "Discretionary Budget" }
}

class NecessaryBudget: Budget {
    @AppStorage("necessaryBudget") var amountLocal: String = "0.0"
    override var amount: String {
        get { amountLocal }
        set {
            amountLocal = newValue
            objectWillChange.send()
        }
    }
    override var label: String { "Necessary Budget" }
}
