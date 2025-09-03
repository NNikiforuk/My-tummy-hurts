//
//  Rows.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct Row: Identifiable, Equatable {
    var id = UUID()
    var text = ""
}

struct AddEditRows: View {
    @Binding var newItems: String
    @Binding var rows: [Row]
    
    let meal: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: meal ? "Meal ingredients" : "Negative symptoms")
            NewRows(newNote: $newItems, rows: $rows, meal: meal)
            Button {
                onAddRow(rows: &rows)
            } label: {
                PlusIcon()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func onAddRow(rows: inout [Row]) {
        rows.append(.init())
    }
}

struct NewRows: View {
    @Binding var newNote: String
    @Binding var rows: [Row]
    
    let meal: Bool
    
    var body: some View {
        ForEach($rows, id: \.id) { $row in
            let id: UUID = $row.wrappedValue.id
            
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
                .onChange(of: row.text) { newValue in
                    newNote = rows
                        .map(\.text)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                }
                
                Button {
                    withAnimation {
                        onDeleteRow(rows: &rows, id: id)
                    }
                } label: {
                    Image(systemName: "xmark")
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 10)
        .animation(.default, value: rows)
    }
    
    private func onDeleteRow(rows: inout [Row], id: UUID) {
        if let index = rows.firstIndex(where: { $0.id == id }) {
            rows.remove(at: index)
        }
        if rows.isEmpty { rows = [.init()] }
    }
}

struct TopNoteRow: View {
    let time: Date
    let critical: Bool?
    
    init(time: Date, critical: Bool? = nil) {
        self.time = time
        self.critical = critical
    }
    
    var body: some View {
        HStack(spacing: 10) {
            NoteIcon(icon: "clock")
            Text(time, style: .time)
            if let critical {
                Circle()
                    .fill(critical ? SymptomTagsEnum.red.color : SymptomTagsEnum.blue.color)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

struct BottomNoteRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            NoteIcon(icon: "carrot")
            Text(text)
                .lineLimit(1)
        }
    }
}

struct NoteIcon: View {
    let icon: String
    
    var body: some View {
        Image(systemName: icon)
            .frame(width: 28)
    }
}

