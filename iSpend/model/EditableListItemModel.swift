//
//  EditabelListItemModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData

@Model
final class EditableListItem {
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
