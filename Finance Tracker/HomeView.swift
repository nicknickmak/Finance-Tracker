import SwiftUI

struct BudgetCategory: Identifiable {
    let id: UUID
    let name: String
    let allocated: Double
    var spendings: [Spending]
    var spent: Double { // Computed from spendings
        spendings.reduce(0) { $0 + $1.amount }
    }

    init(id: UUID = UUID(), name: String, allocated: Double, spendings: [Spending]) {
        self.id = id
        self.name = name
        self.allocated = allocated
        self.spendings = spendings
    }
}

struct Spending: Identifiable, Decodable {
    let id: UUID
    let amount: Double
    let date: Date
    let category: String
    let description: String
}

class HomeViewModel: ObservableObject {
    @Published var categories: [BudgetCategory] = []
    @Published var expandedCategoryIDs: Set<UUID> = []

    func fetchSpendings() {
        // Replace with your API call
        // For now, mock data
        let mockSpendings = [
            Spending(id: UUID(), amount: 20, date: Date(), category: "Food", description: "Lunch"),
            Spending(id: UUID(), amount: 10, date: Date(), category: "Food", description: "Coffee"),
            Spending(id: UUID(), amount: 50, date: Date(), category: "Transport", description: "Taxi"),
            Spending(id: UUID(), amount: 100, date: Date(), category: "Shopping", description: "Clothes")
        ]
        let allocations = [
            ("Food", 200.0),
            ("Transport", 100.0),
            ("Shopping", 300.0)
        ]
        categories = allocations.map { (name, allocated) in
            let spendings = mockSpendings.filter { $0.category == name }.sorted { $0.date > $1.date }
            return BudgetCategory(name: name, allocated: allocated, spendings: spendings)
        }
    }

    func toggleCategory(_ id: UUID) {
        if expandedCategoryIDs.contains(id) {
            expandedCategoryIDs.remove(id)
        } else {
            expandedCategoryIDs.insert(id)
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.categories) { category in
                    Section(header:
                        HStack {
                            VStack(alignment: .leading) {
                                Text(category.name).font(.headline)
                                Text("Spent: $\(category.spent, specifier: "%.2f") / $\(category.allocated, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: viewModel.expandedCategoryIDs.contains(category.id) ? "chevron.down" : "chevron.right")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleCategory(category.id)
                        }
                    ) {
                        if viewModel.expandedCategoryIDs.contains(category.id) {
                            ForEach(category.spendings) { spending in
                                VStack(alignment: .leading) {
                                    Text(spending.description)
                                    Text("$\(spending.amount, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(spending.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Budgets")
            .onAppear { viewModel.fetchSpendings() }
        }
    }
}

#Preview {
    HomeView()
}
