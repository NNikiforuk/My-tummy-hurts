////
////  ContentView.swift
////  My tummy hurts
////
////  Created by Natalia Nikiforuk on 03/09/2025.
////
//
//import SwiftUI
//import CoreData
//
//struct ContentView: View {
//    @StateObject var vm: ViewModel = ViewModel()
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if vm.mealNotes.count == 0 {
//                    Text("No note saved yet. Press the New button to create one")
//                        .bold()
//                        .foregroundColor(.secondary)
//                } else {
//                    List {
//                        ForEach(vm.mealNotes) { note in
//                            HStack {
//                                VStack(alignment: .leading) {
//                                    HStack {
//                                        Text(note.ingredients ?? "")
//                                            .font(.title3)
//                                            .lineLimit(1)
//                                            .bold()
//                                        
//                                        Text(note.createdAt ?? Date(), style: .date)
//                                            .lineLimit(1)
//                                    }
//                                }
//                                Spacer()
//                            }
//                            .swipeActions {
//                                Button(role: .destructive) {
//                                    vm.deleteMealNote(mealNote: note)
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .toolbar {
//                Button("New") {
//                    vm.showAlert = true
//                }
//                .alert(vm.ingredients, isPresented: $vm.showAlert, actions: {
//                    TextField("Title", text: $vm.ingredients)
//                    Button("Save", action: {
//                        vm.createMealNote()
//                        vm.clearStates()
//                    })
//                    Button("Cancel", role: .cancel, action: { vm.clearStates() })
//                }) {
//                    Text("Create a new note")
//                }
//            }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
