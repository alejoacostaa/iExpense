//
//  ContentView.swift
//  iExpense
//
//  Created by Alejo Acosta on 10/04/2021.
//

import SwiftUI







struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name : String
    let type : String
    let amount : Int
}

class Expenses : ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }
        self.items = []
    }
    
    
    
    
}



struct priceStyleModifier: ViewModifier {
    let priceAmount : Int
    func body(content: Content) -> some View {
        content
            .padding()
            //.fontWeight(.bold)
            
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(priceAmount < 11 ? Color.red : Color.green, lineWidth: 5))
    }
}

extension View {
    func amountStyleModifier(priceAmount : Int) -> some View {
        modifier(priceStyleModifier(priceAmount: priceAmount))
    }
}


struct ContentView : View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false
    var body: some View {
        NavigationView {
            List {
                ForEach(expenses.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        Spacer()
                        Text("$\(item.amount)")
                            .amountStyleModifier(priceAmount: item.amount)
                    }
                }
                .onDelete(perform: removeItems)
            }
            
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                self.showingAddExpense = true
            }, label: {
                Image(systemName: "plus")
            }))
            
        }
        
        .sheet(isPresented: $showingAddExpense) {
            //show an addView here
            AddView(expenses: self.expenses)
        }
    }
    
    func removeItems(at offset: IndexSet) {
        expenses.items.remove(atOffsets: offset)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
