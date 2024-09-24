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
let UNDEFINED : Int = 0

@Model
final class EditableListItem:  ObservableObject {
    var id = UUID()
    var text: String = ""
    var type: Int = UNDEFINED
    
    init(text: String = "", type: Int = CATEGORY) {
        self.text = text
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
