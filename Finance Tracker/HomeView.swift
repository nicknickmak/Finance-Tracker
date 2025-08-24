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

struct Spending: Identifiable, Codable {
    let id: String
    let amount: Double
    let date: Date
    let category: String
    let description: String
}

class HomeViewModel: ObservableObject {
    @Published var categories: [BudgetCategory] = []
    @Published var expandedCategoryIDs: Set<UUID> = []

    func fetchSpendings() {
        guard let url = URL(string: "http://127.0.0.1:8000/transactions") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                decoder.dateDecodingStrategy = .formatted(formatter) // Matches backend date format
                
                print("Raw data: \(String(data: data, encoding: .utf8) ?? "nil")")
                let spendings = try decoder.decode([Spending].self, from: data)
                print("Decoded spendings count: \(spendings.count)")
                let allocations = [
                    ("Food", 200.0),
                    ("Transport", 100.0),
                    ("Shopping", 300.0)
                ]
                let newCategories = allocations.map { (name, allocated) in
                    print("Processing category: \(name), allocated: \(allocated)")
                    let filtered = spendings.filter { $0.category == name }.sorted { $0.date > $1.date }
                    print("Spendings for \(name): \(filtered.count)")
                    return BudgetCategory(name: name, allocated: allocated, spendings: filtered)
                }
                DispatchQueue.main.async {
                    print("Updating categories on main thread")
                    self.categories = newCategories
                }
            } catch {
                print("Failed to decode spendings: \(error)")
            }
        }
        task.resume()
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
