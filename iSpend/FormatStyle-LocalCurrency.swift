//
//  FormatStyle-LocalCurrency.swift
//  Revisit
//
//  Created by Spencer Marks on 5/9/24.
//

import Foundation

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Currency {
    static var localCurrency: Self {
        .currency(code: Locale.current.currency?.identifier ?? "USD")
    }
}
