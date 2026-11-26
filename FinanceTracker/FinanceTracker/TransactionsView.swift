import PhotosUI
import SwiftUI
import UIKit

/// Prefill for the Add sheet produced by receipt OCR.
private struct ReceiptPrefill: Identifiable {
    let id = UUID()
    var description: String
    var amountText: String
}

struct TransactionsView: View {
    @EnvironmentObject var store: Store
    @State private var search = ""
    @State private var filter = "All"          // All, Spending, Income, Pending
    @State private var categoryFilter: String? = nil
    @State private var showAdd = false
    @State private var confirmedIDs: Set<UUID> = []
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var receiptPrefill: ReceiptPrefill? = nil

    private let filters = ["All", "Spending", "Income", "Pending"]
    private var categories: [String] {
        Array(Set(store.transactions.map { $0.category })).sorted()
    }

    private var visible: [Transaction] {
        store.transactions.filter { tx in
            if !search.isEmpty && !tx.description.localizedCaseInsensitiveContains(search) { return false }
            if let categoryFilter, tx.category != categoryFilter { return false }
            switch filter {
            case "Spending": return tx.amount < 0
            case "Income": return tx.amount > 0
            case "Pending": return tx.isPending
            default: return true
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Picker("Filter", selection: $filter) {
                    ForEach(filters, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        chip("All categories", selected: categoryFilter == nil) { categoryFilter = nil }
                        ForEach(categories, id: \.self) { category in
                            chip(category, selected: categoryFilter == category) { categoryFilter = category }
                        }
                    }
                    .padding(.horizontal)
                }

                List(visible) { tx in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(tx.description).font(.subheadline).bold()
                            Spacer()
                            Text(money(tx.amount, signed: tx.amount > 0))
                                .font(.subheadline).bold()
                                .foregroundStyle(tx.amount > 0 ? Color.ftTealText : .primary)
                        }
                        HStack(spacing: 6) {
                            Text(tx.date.shortDay).font(.caption).foregroundStyle(.secondary)
                            Text(tx.category)
                                .font(.caption).bold()
                                .foregroundStyle(Color.ftTealText)
                                .padding(.horizontal, 6).padding(.vertical, 1)
                                .background(Color.ftTealSoft).clipShape(Capsule())
                            if tx.isAutoCategorized {
                                Text("Auto").font(.caption).foregroundStyle(Color.ftTealText)
                            }
                            if tx.isSplit {
                                Text("Split").font(.caption).bold()
                                    .foregroundStyle(Color.ftAmberText)
                                    .padding(.horizontal, 6).padding(.vertical, 1)
                                    .background(Color.ftAmberSoft).clipShape(Capsule())
                            }
                            if tx.isPending {
                                Text("Pending").font(.caption).bold()
                                    .foregroundStyle(Color.ftAmberText)
                                    .padding(.horizontal, 6).padding(.vertical, 1)
                                    .background(Color.ftAmberSoft).clipShape(Capsule())
                            }
                            if tx.isRecurring {
                                Label("Recurring", systemImage: "repeat").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        // Auto-categorisation prompts to confirm — never silent.
                        if tx.needsCategoryConfirm && !confirmedIDs.contains(tx.id) {
                            HStack(spacing: 8) {
                                Text("Confirm category “\(tx.category)”?")
                                    .font(.caption).foregroundStyle(.secondary)
                                Button("Confirm") { confirmedIDs.insert(tx.id) }
                                    .font(.caption).bold()
                                Button("Change") { confirmedIDs.insert(tx.id) }
                                    .font(.caption)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Transactions")
            .searchable(text: $search, prompt: "Search payee, amount, tag…")
            .toolbar {
                Menu {
                    Button { showAdd = true } label: {
                        Label("Add transaction", systemImage: "plus")
                    }
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button { showCamera = true } label: {
                            Label("Scan receipt", systemImage: "camera.viewfinder")
                        }
                    }
                    Button { showPhotoPicker = true } label: {
                        Label("Import receipt photo", systemImage: "photo")
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showAdd) { AddTransactionView() }
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in handleReceiptImage(image) }
                    .ignoresSafeArea()
            }
            .sheet(item: $receiptPrefill) { prefill in
                AddTransactionView(initialDescription: prefill.description,
                                   initialAmountText: prefill.amountText)
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        handleReceiptImage(image)
                    }
                    photoItem = nil
                }
            }
        }
    }

    /// OCR runs on-device; the result only prefills the Add sheet —
    /// nothing is saved until the user confirms it there.
    private func handleReceiptImage(_ image: UIImage) {
        ReceiptScanner.recognize(image) { draft in
            guard let draft else { return }
            receiptPrefill = ReceiptPrefill(
                description: draft.merchant,
                amountText: draft.total.map { String(format: "%.2f", $0) } ?? "")
        }
    }

    private func chip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption).bold()
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(selected ? Color.ftTealDeep : Color.ftSurface)
                .foregroundStyle(selected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(selected ? Color.clear : Color.secondary.opacity(0.35), lineWidth: 1)
                )
        }
    }
}

struct AddTransactionView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var description: String
    @State private var amountText: String
    @State private var category: String
    @State private var isIncome = false
    @State private var accountID: UUID? = nil

    /// Prefill values — used by receipt scanning so the user confirms
    /// or edits the OCR result before it is saved.
    init(initialDescription: String = "", initialAmountText: String = "",
         initialCategory: String = "Groceries") {
        _description = State(initialValue: initialDescription)
        _amountText = State(initialValue: initialAmountText)
        _category = State(initialValue: initialCategory)
    }

    private let categoryOptions = ["Groceries", "Dining", "Transport", "Shopping", "Bills", "Gifts", "Income", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Description", text: $description)
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                Toggle("Income (money in)", isOn: $isIncome)
                Picker("Category", selection: $category) {
                    ForEach(categoryOptions, id: \.self) { Text($0) }
                }
                Picker("Account", selection: $accountID) {
                    Text("No account").tag(UUID?.none)
                    ForEach(store.accounts) { account in
                        Text(account.name).tag(Optional(account.id))
                    }
                }
            }
            .navigationTitle("Add transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let value = Double(amountText) ?? 0
                        guard value != 0, !description.isEmpty else { return }
                        store.transactions.insert(
                            Transaction(date: Date(), description: description,
                                        category: isIncome ? "Income" : category,
                                        amount: isIncome ? abs(value) : -abs(value),
                                        accountID: accountID),
                            at: 0)
                        dismiss()
                    }
                }
            }
        }
    }
}
