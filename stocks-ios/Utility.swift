//
//  Utility.swift
//  stocks-ios
//
//  Created by Parag Jadhav on 4/4/24.
//

import UIKit
import Foundation
import SwiftUI

class Utility {
    
    public static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    // Helper to format currency
    public static func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        
    }
    
    public static func formatVal(_ value: Double) -> String {
        let roundedValue = String(format: "%.2f", value)
        return roundedValue
    
    }
    
    
    

}
