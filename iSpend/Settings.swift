//
//  Settings.swift
//  iSpend
//
//  Created by Spencer Marks on 3/5/24.
//

import Foundation

final class Settings: ObservableObject {
    
    
    @Published var appVersion: String {
        didSet {
            appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        }
    }

    init() {
       
        self.appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
}
