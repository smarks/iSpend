//
//  MediationsModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData

@Model
final class MediationsModel {
    var mediations:[String]
    
    init(mediations: [String]) {
        self.mediations = mediations
    }
    
}

