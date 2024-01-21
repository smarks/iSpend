//
//  ExpenseItem.swift
//  iSpent
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import Foundation

struct ExpenseItem: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let type: ExpenseType
    let amount: Double
    let note: String
    let date: Date    
}
