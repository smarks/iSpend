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

    var body: some View {
        VStack {
            Text("Settings").bold()
      
            HStack {
                Text("Current Discretionary Budget:")
                Text(settings.discretionaryBudget, format: .localCurrency)
            }.fixedSize()
            
            HStack{
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
    }
}

// new class Theme inherting from ObservableObject
final class Settings: ObservableObject {
    @Published var discretionaryBudget: Double = 0.0
    @Published var necessaryBudget: Double = 0.0
}
