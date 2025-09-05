//
//  Rows.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct AddNewNote: View {
    @Binding var newItems: String
    @Binding var rows: [Row]
    
    let meal: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: meal ? "Meal ingredients" : "Negative symptoms")
            NewRows(newNote: $newItems, rows: $rows, meal: meal)
            AppendingRowBtn(rows: $rows)
        }
    }
}

struct NewRows: View {
    @Binding var newNote: String
    @Binding var rows: [Row]
    
    let meal: Bool
    
    var body: some View {
        ForEach($rows) { $row in
            let id = row.id
            
            HStack(spacing: 8) {
                TextField(
                    meal ? "cow milk" : "diarrhea",
                    text: $row.text)
                .disableAutocorrection(true)
                .padding(5)
                .padding(.horizontal, 10)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(UIColor.gray), lineWidth: 1)
                }
                .lineLimit(1)
                .textInputAutocapitalization(.never)
                .onChange(of: rows.map(\.text)) { texts in
                    newNote = texts
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                }
                .onAppear {
                    let texts = rows.map(\.text)
                    newNote = texts
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                }
                Button {
                    withAnimation {
                        if rows.count == 1 {
                            if let index = rows.firstIndex(where: { $0.id == id }) {
                                rows[index].text = ""
                            }
                        } else {
                            rows.removeAll { $0.id == id }
                        }
                    }
                } label: {
                    Image(systemName: "xmark")
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 10)
    }
}

