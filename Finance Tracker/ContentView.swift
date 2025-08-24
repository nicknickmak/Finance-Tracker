//
//  ContentView.swift
//  Finance Tracker
//
//  Created by Nick Mak on 8/24/25.
//

import SwiftUI

//
struct Transaction: Identifiable {
    let id = UUID()
    let amount: Double
    let date: Date
    let category: String
    let description: String
}

struct ContentView: View {
    @State private var transactions: [Transaction] = [
        Transaction(amount: 20.0, date: Date(), category: "Food", description: "Lunch"),
        Transaction(amount: 50.0, date: Date(), category: "Transport", description: "Taxi"),
        Transaction(amount: 100.0, date: Date(), category:
                   "Shopping", description: "Clothes")
    ]

    var body: some View {
        NavigationView {
            List(transactions) { transaction in
                VStack(alignment: .leading) {
                    Text(transaction.description)
                    Text(transaction.category)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("$\(transaction.amount, specifier: "%.2f")")
                        .font(.headline)
                }
            }
            .navigationTitle("Transactions")
        }
    }
}

#Preview {
    ContentView()
}
