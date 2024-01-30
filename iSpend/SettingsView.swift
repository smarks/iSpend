//
//  SettingsView.swift
//  iSpend
//
//  Created by Spencer Marks on 1/24/24.
//

import Foundation
import SwiftUI

struct SettingView: View {
    @EnvironmentObject var settings: Settings
    @State private var stringNecessaryAmount = "0.0"
    @State private var stringDiscretionaryAmount = "0.0"
    @State var isPresentingConfirm: Bool = false
    @EnvironmentObject var expenses: Expenses
 

    var body: some View {
        VStack {
            Text("Settings").bold()

            HStack {
                Text("Current Discretionary Budget:")
                Text(settings.discretionaryBudget, format: .localCurrency)
            }.fixedSize()

            HStack {
                Text("Revised Discretionary Budget:")
                NumericTextField(numericText: $stringDiscretionaryAmount, amountDouble: $settings.discretionaryBudget).border(Color.blue, width: 1)
            }.fixedSize()

            HStack {
                Text("Current Necessary Budget:")
                Text(settings.necessaryBudget, format: .localCurrency)
            }.fixedSize()
            HStack {
                Text("Revised Necessary Budget:")
                NumericTextField(numericText: $stringNecessaryAmount, amountDouble: $settings.necessaryBudget).border(Color.blue, width: 1)
            }.fixedSize()
        }
        Section {
            Spacer()
            HStack {
                Button("Reset", role: .destructive) {
                    isPresentingConfirm = true
                }.confirmationDialog("Are you sure?",
                                     isPresented: $isPresentingConfirm) {
                    Button("Delete all data and restore defaults?", role: .destructive) {
                        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
                            UserDefaults.standard.removeObject(forKey: key)
                        }
                        expenses.loadData()
                    }
                   
                    
                     
                }
                Button("Export") {
                    print("Export")
                }
            }
        }
    }
}

// new class Theme inherting from ObservableObject
final class Settings: ObservableObject {
    @Published var discretionaryBudget: Double {
        didSet{  if let encoded = try? JSONEncoder().encode(discretionaryBudget) {
            UserDefaults.standard.set(encoded, forKey: "discretionaryBudget")
          
        } else {
            self.discretionaryBudget = 0.0
        }}
    }
    @Published var necessaryBudget: Double{
        didSet{
            if let encoded = try? JSONEncoder().encode(necessaryBudget) {
                UserDefaults.standard.set(encoded, forKey: "necessaryBudget")
               
            } else {
                self.necessaryBudget = 0.0
            }
        }
    }
    @Published var appVersion: String {
        didSet{
            appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        }
    }
    
    init() {
       
        self.necessaryBudget = 0.0
        self.discretionaryBudget = 0.0
        self.appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        
    }
    
    
}
