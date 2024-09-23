//
//  EditabelListItemModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData
 
 

let CATEGORY: Int = 1
let MEDIATION: Int = 2

@Model
final class EditableListItem: Identifiable {
    var id = UUID()
    var text: String
    var type: Int
    init(text: String = "", type: Int = CATEGORY) {
        self.text = text
        self.id = UUID()
        self.type = type
    }
}
  

/*
 class Mediations: Labels {
     @AppStorage("Mediations") var list: [String] = [
         "don't", "What would you do without it?",
         "What would you do without it?",
         "Sometimes its' OK to reward yourself.",
         "Learn from the past, and plan for the future, while living in the present."]
 }
 */
