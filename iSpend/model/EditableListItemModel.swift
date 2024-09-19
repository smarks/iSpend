//
//  EditabelListItemModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData

protocol EditableListItems {
    var items: [EditableListItem] { get set }
}

struct EditableListItem: Identifiable {
    var id = UUID()
    var text: String
    init(text: String = "") {
        self.text = text
        id = UUID()
    }
}
@Model
final class CatergoriesModel:EditableListItems {
    var items: [EditableListItem]

    init(items: [EditableListItem]) {
        self.items = items
    }
}

@Model
final class MediationsModel: EditableListItems {
    var items: [EditableListItem]

    init(items: [EditableListItem]) {
        self.items = items
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
