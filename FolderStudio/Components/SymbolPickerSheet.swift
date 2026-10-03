//
//  SymbolPickerSheet.swift
//  FolderStudio
//

import SwiftUI

struct SymbolPickerSheet: View {
    @Binding var selectedSymbol: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedCategoryId: String = "popular"
    
    private let columns = [
        GridItem(.adaptive(minimum: 44, maximum: 54), spacing: 8)
    ]
    
    var displayedSymbols: [String] {
        if !searchText.isEmpty {
            return SFSymbolCatalog.search(query: searchText)
        }
        if selectedCategoryId == "all" {
            return SFSymbolCatalog.allSymbols
        }
        if let category = SFSymbolCatalog.categories.first(where: { $0.id == selectedCategoryId }) {
            return category.symbols
        }
        return SFSymbolCatalog.allSymbols
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Choose SF Symbol")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            
            Divider()
            
            // Search Bar & Custom Input
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search symbols or type exact SF Symbol name...", text: $searchText)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Category Selector Tabs
            if searchText.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        Button {
                            selectedCategoryId = "all"
                        } label: {
                            Text("All")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(selectedCategoryId == "all" ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                                .foregroundColor(selectedCategoryId == "all" ? .white : .primary)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(SFSymbolCatalog.categories) { category in
                            Button {
                                selectedCategoryId = category.id
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 10))
                                    Text(category.name)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(selectedCategoryId == category.id ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                                .foregroundColor(selectedCategoryId == category.id ? .white : .primary)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
            }
            
            Divider()
                .padding(.top, 8)
            
            // Symbols Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(displayedSymbols, id: \.self) { symbol in
                        Button {
                            selectedSymbol = symbol
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedSymbol == symbol ? Color.accentColor.opacity(0.18) : Color(NSColor.controlBackgroundColor).opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedSymbol == symbol ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                    )
                                
                                Image(systemName: symbol)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedSymbol == symbol ? .accentColor : .primary)
                            }
                            .frame(height: 44)
                        }
                        .buttonStyle(.plain)
                        .help(symbol)
                    }
                }
                .padding(20)
            }
        }
        .frame(width: 580, height: 460)
    }
}
