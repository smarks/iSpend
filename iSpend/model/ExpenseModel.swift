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
 
let NECESSARY:Int = 1
let DISCRETIONARY:Int = 2

 
@Model
final class ExpenseModel {
    var name: String
    var type: Int
    var amount: Double
    var note: String
    var date: Date
    var category: String
    var discretionaryValue: Double
    
    init(name:String = "Description", type:Int = NECESSARY, amount:Double = 0, note:String="Notes", date: Date=Date(), category:String = "None", discretionaryValue: Double=0){
        self.name = name
        self.type = type
        self.amount = amount
        self.note = note
        self.date = date
        self.category = category
        self.discretionaryValue = discretionaryValue
    }
}

 
