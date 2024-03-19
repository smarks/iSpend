//
//  Cats.swift
//  iSpend
//
//  Created by Spencer Marks on 3/19/24.
//

import Foundation

import Foundation
import SwiftUI

class StringValue: ObservableObject {
    var string: String {
        get { "0.0" }
        set { }
    }

    var label: String { "Undefined" }
}

class CategoriesDos {
   
    @AppStorage("categories") var values: [StringValue] = []

    get { values }
    set {
        values = newValue
        objectWillChange.send()
    }
    
}
 
