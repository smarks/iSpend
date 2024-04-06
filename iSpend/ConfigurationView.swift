import Combine
import Foundation
import SwiftUI

struct ConfigurationView: View {
    @Environment(\.dismiss) var dismiss

    @State private var showingSheet = false
    @State private var editingText: String = ""
    @Binding var items: [String] // Use a binding to allow the view to modify the array
    var title: String

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { stringToShow in
                    Text(stringToShow)
                }
                .onDelete(perform: remove) // Use onDelete here
            }
            .navigationTitle(title)
            .toolbar {
                Button {
                    editingText = ""
                    showingSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            EditLabelView(itemText: editingText, editTitle: title) { newText in
                if !newText.isEmpty {
                    items.append(newText)
                    showingSheet = false
                }
            }
        }
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
struct EditLabelView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (String) -> Void
    @State private var itemText: String
    var editTitle: String

    init(itemText: String = "", editTitle: String = "Add", onSave: @escaping (String) -> Void) {
        _itemText = State(initialValue: itemText)
        self.editTitle = editTitle
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter item", text: $itemText)
                    .padding(.horizontal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .navigationTitle(editTitle)
            .navigationBarTitleDisplayMode(.inline)
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

protocol Labels: ObservableObject {
    var list: [String] { get   }
     

}

class Categories: Labels {
    static let defaultValue: String = "None"

    @AppStorage("Categories")  var list: [String] = [
        defaultValue, "Restaurant", "Misc", "HouseHold", "Hobby"]
}

class Mediations: Labels {
    @AppStorage("Mediations") var list: [String] = [
        "don't", "What would you do without it?",
        "What would you do without it?",
        "Sometimes its' OK to reward yourself.",
        "Learn from the past, and plan for the future, while living in the present."]
}
