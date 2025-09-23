//
//  Test.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 23/09/2025.
//

import SwiftUI

struct DemoView: View {
    @State private var firstText: String = ""
    @State private var secondText: String = ""
    @State private var showSecond = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("", text: $firstText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            if showSecond {
                TextField("", text: $secondText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            typeText("cow milk", into: $firstText) {
                // po skończeniu pierwszego
                withAnimation {
                    showSecond = true
                }
                // delay i typing drugiego
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    typeText("bread", into: $secondText, completion: nil)
                }
            }
        }
    }
    
    private func typeText(_ text: String, into binding: Binding<String>, completion: (() -> Void)?) {
        for (i, char) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * Double(i)) {
                binding.wrappedValue.append(char)
                if i == text.count - 1 {
                    completion?()
                }
            }
        }
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DemoView()
        }
    }
}
