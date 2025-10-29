//
//  HistoryView.swift
//  Viz
//
//  Created by Alin Lupascu on 3/27/25.
//
import SwiftUI
import AlinFoundation

struct HistoryView: View {
    @ObservedObject private var historyState = HistoryState.shared
    @State private var tappedItemID: String?
    @State private var filterSelection = "All"
    private let filters = ["All", "Text", "Colors"]
    private var filteredItems: [HistoryEntry] {
        historyState.historyItems
            .reversed()
            .filter { item in
                switch filterSelection {
                case "Text":
                    if case .text = item { return true }
                    return false
                case "Colors":
                    if case .color = item { return true }
                    return false
                default:
                    return true
                }
            }
    }

    var body: some View {

        VStack(alignment: .center, spacing: 0) {

            Text("History")
                .font(.title)
                .padding(.vertical)

            Spacer()

            if filteredItems.isEmpty {
                Text(filterSelection == "All" ? "No items have been captured" : filterSelection == "Text" ? "No text has been captured" : "No colors have been captured").foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(filteredItems) { item in
                            HStack {
                                switch item {
                                case .color(let colorItem):
                                    HStack(alignment: .center, spacing: 0) {
                                        VStack(alignment: .leading) {
                                            Text("HEX: \(colorItem.hex)")
                                            Text("RGB: \(colorItem.rgb)")
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                                .onTapGesture {
                                                    tappedItemID = colorItem.id
                                                    copyToClipboard(colorItem.rgb)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                        tappedItemID = nil
                                                    }
                                                }
                                        }
                                        .frame(width: 100)
                                        .padding()
                                        TrailingRoundedRectangle(cornerRadius: 8)
                                            .fill(colorItem.color)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.secondary.opacity(0.1))
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(.secondary.opacity(0.3))
                                    }
                                    .animation(.easeInOut(duration: 0.2), value: tappedItemID)
                                    .onTapGesture {
                                        tappedItemID = colorItem.id
                                        copyToClipboard(colorItem.hex)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            tappedItemID = nil
                                        }
                                    }
                                case .text(let textItem):
                                    HStack {
                                        HStack(alignment: .center, spacing: 0) {
                                            let trimmed = textItem.text.trimmingCharacters(in: .whitespacesAndNewlines)
                                            if isRecognizedURLFormat(trimmed),
                                               let url = URL(string: trimmed.hasPrefix("http") ? trimmed : "https://\(trimmed)") {
                                                Button {
                                                    NSWorkspace.shared.open(url)
                                                } label: {
                                                    Image(systemName: "safari")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 14, height: 14)
                                                        .foregroundColor(.blue)
                                                        .padding(.trailing)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            Text(textItem.text)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.secondary.opacity(0.1))
                                        }
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(.secondary.opacity(0.3))
                                        }
                                        .animation(.easeInOut(duration: 0.2), value: tappedItemID)
                                        .onTapGesture {
                                            tappedItemID = textItem.id
                                            copyToClipboard(textItem.text)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                tappedItemID = nil
                                            }
                                        }
                                    }
                                }


                                // Delete item button
                                Button(action: {
                                    switch item {
                                    case .text(let textItem):
                                        if tappedItemID != textItem.id {
                                            historyState.historyItems.removeAll { $0.id == item.id }
                                        }
                                    case .color(let colorItem):
                                        if tappedItemID != colorItem.id {
                                            historyState.historyItems.removeAll { $0.id == item.id }
                                        }
                                    }
                                }) {
                                    Image(systemName: tappedItemID == item.id ? "checkmark" : "xmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(tappedItemID == item.id ? .green : .secondary)
                                        .padding(.horizontal, 5)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
                .scrollIndicators(.never)
            }

            Spacer()

            HStack {
                Picker("", selection: $filterSelection) {
                    ForEach(filters, id: \.self) { filter in
                        Text(filter).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
                .padding(.leading)

                Spacer()

                Button {
                    clearClipboard()
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(5)
                        .padding(.leading, 1)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(.vertical)


        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(Color("bg")
        )
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)

    }
}

// Helper function for recognized URL formats
func isRecognizedURLFormat(_ text: String) -> Bool {
    let pattern = #"^(https?:\/\/)?(www\.)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}.*$"#
    return text.range(of: pattern, options: .regularExpression) != nil
}
