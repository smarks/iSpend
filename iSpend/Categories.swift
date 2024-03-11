//
//  Expenses.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import Foundation
//

struct Category: Identifiable, Codable, Equatable, Hashable {
  
    var id = UUID()
    var name: String


    init() {
        id = UUID()
        name = ""
 
    }

    init(id: UUID, name: String){

        self.id = id
        self.name = name
    
    }
}

class Categories: ObservableObject {
    
     let defaultCategory = Category(id:UUID(), name:"None")
     let resurantCategory = Category(id:UUID(), name:"Resturant")
     let hobbyCategory = Category(id:UUID(), name:"Hobby")
     let houseHoldCategory = Category(id:UUID(), name:"HouseHold")

    
    @Published var all = [Category]() {
        
        didSet {

            if let encoded = try? JSONEncoder().encode(all) {
                UserDefaults.standard.set(encoded, forKey: "Categories")
            }
        }
    }

   

    init() {
      loadData()
    }
    
    func loadData() {
        if let savedItems = UserDefaults.standard.data(forKey: "Categories") {
            if let decodedItems = try? JSONDecoder().decode([Category].self, from: savedItems) {
                all = decodedItems
                if all.isEmpty {
                    all.append(defaultCategory)
                    all.append(resurantCategory)
                    all.append(houseHoldCategory)
                    all.append(hobbyCategory)
                }
              
                return
            }
        }
        all = []
        all.append(defaultCategory)
        all.append(resurantCategory)
        all.append(houseHoldCategory)
        all.append(hobbyCategory)

    }
}
