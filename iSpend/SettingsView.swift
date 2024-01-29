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
    @State private var stringAmount = "0.0"

    var body: some View {
        VStack {
            Text("Settings").bold()
            HStack{
                Text("Current Budget:")
                Text(settings.budget, format: .localCurrency)
            }
            HStack {
                Text("Revised Budget:") 
                NumericTextField(numericText: $stringAmount, amountDouble: $settings.budget)
            }
        }
    }
}

// new class Theme inherting from ObservableObject
final class Settings: ObservableObject {
    @Published var budget: Double = 0.0
}
