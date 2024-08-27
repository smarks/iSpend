//
//  CatergoriesModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData

@Model
final class CatergoriesModel {
    var categories:[String]
    
    init(categories: [String]) {
        self.categories = categories
    }
    
}
