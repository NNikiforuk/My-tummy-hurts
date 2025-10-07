//
//  SelectElementPicker.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct SelectElementPicker: View {
    let pickerData: [String]
    
    @Binding var pickerSelection: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let selection = Binding<String?>(
                get: { pickerSelection },
                set: { newValue in
                    let v = newValue?.normalizedToken ?? ""
                    pickerSelection = v.isEmpty ? nil : v
                }
            )
            
            Picker(selection: selection) {
                Text("None").tag(nil as String?)
                ForEach(pickerData, id: \.self) { el in
                    Text(el).tag(el as String?)
                }
            } label: {
                Text((pickerSelection?.isEmpty == false ? pickerSelection! : "Select"))
                    .lineLimit(1).truncationMode(.tail).minimumScaleFactor(0.9)
                    .foregroundStyle(.accent)
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("BackgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("SecondaryText").opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .pickerStyle(.menu)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("BackgroundColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("SecondaryText").opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .onAppear(perform: coerceSelectionToOptions)
        .onChange(of: pickerData) { _ in coerceSelectionToOptions() }
    }
    private func coerceSelectionToOptions() {
        let normalizedOptions = pickerData.map { $0.normalizedToken }
        let normalizedSet = Set(normalizedOptions.map { $0.lowercased() })
        guard let rawSel = pickerSelection?.normalizedToken, !rawSel.isEmpty else {
            pickerSelection = nil
            return
        }
        
        let key = rawSel.lowercased()
        guard normalizedSet.contains(key) else {
            pickerSelection = nil
            return
        }
        
        if let canonical = normalizedOptions.first(where: { $0.caseInsensitiveCompare(rawSel) == .orderedSame }) {
            pickerSelection = canonical
        } else {
            pickerSelection = rawSel
        }
    }
}

func dataForPicker(mealsMode: Bool, model: CoreDataViewModel, excluded: String? = nil) -> [String] {
    var array: [String] = []
    
    if mealsMode {
        for note in model.savedMealNotes {
            guard let s = note.ingredients else { continue }
            array.append(contentsOf:
                            s.split(separator: ",").map { String($0).normalizedToken }.filter { !$0.isEmpty }
            )
        }
    } else {
        for note in model.savedSymptomNotes {
            guard let s = note.symptoms else { continue }
            array.append(contentsOf:
                            s.split(separator: ",").map { String($0).normalizedToken }.filter { !$0.isEmpty }
            )
        }
    }
    
    if let ex = excluded?.normalizedToken, !ex.isEmpty {
        array.removeAll { $0.caseInsensitiveCompare(ex) == .orderedSame }
    }
    
    var seen = Set<String>()
    let unique = array.compactMap { item -> String? in
        let key = item.lowercased()
        return seen.insert(key).inserted ? item : nil
    }
    
    return unique.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
}

extension String {
    var normalizedToken: String {
        var s = self
        for j in ["\u{200B}","\u{200C}","\u{200D}","\u{FEFF}","\u{00AD}"] { s = s.replacingOccurrences(of: j, with: "") }
        s = s.replacingOccurrences(of: "\u{00A0}", with: " ")
        s = s.replacingOccurrences(of: #"(?:\r|\n)+"#, with: "", options: .regularExpression)
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: #"[ \t]+"#, with: " ", options: .regularExpression)
        return s
    }
}

extension Binding where Value == String? {
    func normalized() -> Binding<String?> {
        .init(
            get: {
                let v = self.wrappedValue?.normalizedToken
                return (v?.isEmpty == true) ? nil : v
            },
            set: { newValue in
                let v = newValue?.normalizedToken
                self.wrappedValue = (v?.isEmpty == true) ? nil : v
            }
        )
    }
}


