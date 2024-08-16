//
//  ExpenseModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/13/24.
//
 
import Foundation
import SwiftData
import SwiftUI

enum ExpenseType: Int, Codable {
    case Necessary = 1
    case Discretionary = 2
}
 

@Model
final class ExpenseModel {
    var name: String
    var type: ExpenseType
    var amount: Double
    var note: String
    var date: Date
    var category: String
    var discretionaryValue: Double
    
    init(name:String, type:ExpenseType, amount: Double, note:String, date: Date, category:String, discretionaryValue: Double){
        self.name = name
        self.type = type
        self.amount = amount
        self.note = note
        self.date = date
        self.category = category
        self.discretionaryValue = discretionaryValue
    }
}

 
