//
//  BudgetModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData

enum BudgetPeriod: String, Codable, Equatable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"

    var intValue: Int {
        switch self {
        case .weekly: return 1
        case .monthly: return 2
        case .yearly: return 3
        case .custom: return 4
        }
    }

    init(from intValue: Int) {
        switch intValue {
        case 1: self = .weekly
        case 3: self = .yearly
        case 4: self = .custom
        default: self = .monthly
        }
    }
}

@Model
final class BudgetModel {
    var id: UUID = UUID()
    var type: Int = NECESSARY
    var amount: Double = 0

    // Period stored as Int for SwiftData compatibility; default is monthly (2).
    var periodMap: Int = 2
    // Number of days in a custom period; only used when periodMap == 4.
    var customPeriodDays: Int = 30
    // Anchor date for custom rolling periods.
    var periodStartDate: Date = Date()

    var budgetPeriod: BudgetPeriod {
        get { BudgetPeriod(from: periodMap) }
        set { periodMap = newValue.intValue }
    }

    /// The start of the budget's current period.
    var currentPeriodStart: Date {
        let calendar = Calendar.current
        let now = Date()
        switch budgetPeriod {
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .monthly:
            return calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .yearly:
            return calendar.dateInterval(of: .year, for: now)?.start ?? now
        case .custom:
            let days = max(1, customPeriodDays)
            let elapsed = calendar.dateComponents([.day], from: periodStartDate, to: now).day ?? 0
            let periodsElapsed = max(0, elapsed / days)
            return calendar.date(byAdding: .day, value: periodsElapsed * days, to: periodStartDate) ?? periodStartDate
        }
    }

    /// The exclusive end of the budget's current period.
    var currentPeriodEnd: Date {
        let calendar = Calendar.current
        switch budgetPeriod {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: currentPeriodStart) ?? currentPeriodStart
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: currentPeriodStart) ?? currentPeriodStart
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: currentPeriodStart) ?? currentPeriodStart
        case .custom:
            return calendar.date(byAdding: .day, value: max(1, customPeriodDays), to: currentPeriodStart) ?? currentPeriodStart
        }
    }

    /// A human-readable label for the current period, e.g. "Mar 2026" or "Mar 24 – Mar 30".
    var periodLabel: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        switch budgetPeriod {
        case .monthly:
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: currentPeriodStart)
        case .yearly:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: currentPeriodStart)
        case .weekly, .custom:
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: currentPeriodStart)
            let inclusiveEnd = calendar.date(byAdding: .day, value: -1, to: currentPeriodEnd) ?? currentPeriodEnd
            let end = formatter.string(from: inclusiveEnd)
            return "\(start) – \(end)"
        }
    }

    init(type: Int, amount: Double) {
        self.id = UUID()
        self.type = type
        self.amount = amount
        self.periodMap = BudgetPeriod.monthly.intValue
        self.customPeriodDays = 30
        self.periodStartDate = Date()
    }
}
