import Foundation
import SwiftUI

 
// Default categories
let defaultCategory = Category(name: "None")
let restaurantCategory = Category(name: "Restaurant")
let hobbyCategory = Category(name: "Hobby")
let houseHoldCategory = Category(name: "HouseHold")

let categoriesManager = ItemsManager<Category>(itemsKey: "Categories")

struct Category: NamedItem, Identifiable, Codable, Equatable, Hashable {
  
          var id = UUID()
    var name: String

    init() {
             id = UUID()
        name = ""
    }
}

protocol NamedItemCollection {
    func appendItem(item:any NamedItem)
}
class Categories: ObservableObject {
    
    static let  singleInstance:Categories = Categories()
    
    @Published var items: [Category] = categoriesManager.items

    let defaultValue = defaultCategory
    
    private init() {
        if categoriesManager.items.isEmpty {
            categoriesManager.appendItem(item: defaultCategory)
            categoriesManager.appendItem(item:houseHoldCategory)
            categoriesManager.appendItem(item: hobbyCategory)
            categoriesManager.appendItem(item: restaurantCategory)
    }
        // Assign loaded categories to the published items property
        items = categoriesManager.items
    }
    func refreshData(){
        items = categoriesManager.items
    }
    func appendItem(category:Category){
        categoriesManager.appendItem(item: category)
    }
}
