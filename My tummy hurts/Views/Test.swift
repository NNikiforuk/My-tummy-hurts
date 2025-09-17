
//  ContentView.swift
//  My tummy hurts

//  Created by Natalia Nikiforuk on 03/09/2025.


import SwiftUI
import Charts

struct TestView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @State var textFieldText1: String = ""
    @State var textFieldText2: String = ""
    @State var createdAt: Date = Date()
    
    var body: some View {
        NavigationView {
            ForEach(vm.savedMealNotes) { meal in
                Dupa(meal: meal)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .environmentObject(CoreDataViewModel())
    }
}

//VStack(spacing: 20) {
//    TextField("Add symptom here...", text: $textFieldText2)
//    Button {
//        guard !textFieldText2.isEmpty else { return }
//        vm.addSymptom(createdAt: createdAt, symptoms: textFieldText2, critical: true)
//        textFieldText2 = ""
//    } label: {
//        Text("Save")
//    }
//    
//    List {
//        ForEach(vm.savedSymptomNotes) { entity in
//            Text(entity.symptoms ?? "no symptom")
//                .onTapGesture {
//                    vm.updateSymptom(entity: entity)
//                }
//        }
//        .onDelete (perform: vm.deleteSymptom)
//    }
//}
