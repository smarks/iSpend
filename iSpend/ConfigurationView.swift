import Combine
import Foundation
import SwiftUI

struct ConfigurationView: View {
    @Environment(\.dismiss) var dismiss

    @State private var showingAddMediations = false
    @State private var showingAddCategories = false
    @State private var editingText: String = "" // State to hold the text being edited or added

    // Mark categoryItems as @State to allow for mutations
    @State var categories: [String] = Categories().list

    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { stringToShow in
                    Text(stringToShow)
                }
                .onDelete(perform: removeCategories) // Use onDelete here
            }
            .navigationTitle("Categories")
            .toolbar {
                Button {
                    editingText = ""
                    showingAddCategories = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategories) {
            AddOrEditItemView(itemText: editingText) { newText in
                if !newText.isEmpty {
                    categories.append(newText)
                }
            }
        }
    }

    // Function to remove categories, no longer needs to be marked as mutating
    func removeCategories(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }
}

 /*
       NavigationView {
           EditListView(deleteItems: removeMediations, items: $mediationItems)
               .navigationTitle("Mediations")
               .toolbar {
                   Button {
                       editingText = "" // Reset or set to a default value for adding a new item
                       showingAddMediations = true
                   } label: {
                       Image(systemName: "plus")
                   }
               }
       }
       .sheet(isPresented: $showingAddMediations) {
           AddOrEditItemView(itemText: editingText) { newText in
               // Handle saving the edited or new text
               if !newText.isEmpty {
                   mediations.appendItem(mediation: Mediation(name: newText))
               }
           }.environmentObject(mediations)
       }
 */

struct AddOrEditItemView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (String) -> Void
    @State private var itemText: String

    init(itemText: String = "", onSave: @escaping (String) -> Void) {
        _itemText = State(initialValue: itemText)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            TextField("Enter item", text: $itemText)
                .padding()
                .navigationTitle("Edit Item")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            onSave(itemText)
                            dismiss()
                        }
                    }
                }
        }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

class Categories: ObservableObject {
    static let defaultValue: String = "None"

    @AppStorage("Categories") var list: [String] = [
        defaultValue, "Restaurant", "Misc", "HouseHold", "Hobby"]
}

class Mediations: ObservableObject {
    @AppStorage("Mediations") var list: [String] = [
        "don't", "What would you do without it?",
        "What would you do without it?",
        "Sometimes its' OK to reward yourself.",
        "Learn from the past, and plan for the future, while living in the present."]
}
