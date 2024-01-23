//
//  Mediations.swift
//  iSpend
//
//  Created by Spencer Marks on 1/22/24.
//

import Foundation
 
class Mediations: ObservableObject {
    @Published var items = [String]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Mediations")
            }
        }
    }

    var mediations: [String] {
     items
    }


    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Mediations") {
            if let decodedItems = try? JSONDecoder().decode([String].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
     
        items.append("An poke in th eyee  a day")
        items.append("Fine")
    }
}
