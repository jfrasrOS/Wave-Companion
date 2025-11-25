//
//  ContentView.swift
//  Wave-Companion
//
//  Created by John on 25/11/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext


    var body: some View {
        
            Text("wave companion")
        
    }

  
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
