//
//  ExpenseModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/13/24.
//
 
import Foundation
import SwiftData

@Model
final class ExpenseModel {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
