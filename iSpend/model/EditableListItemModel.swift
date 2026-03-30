//
//  EditableListItemModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData

@Model
final class EditableListItem {
    var id: UUID = UUID()
    var text: String = ""
    var type: Int = UNDEFINED

    init(text: String = "", type: Int = CATEGORY) {
        self.id = UUID()
        self.text = text
        self.type = type
    }
}
