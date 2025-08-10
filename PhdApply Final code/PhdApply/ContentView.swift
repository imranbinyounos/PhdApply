//
//  ContentView.swift
//  PhdApply
//
//  Created by Imran on 9/8/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View { MainView() }
}

#Preview {
    ContentView()
        .modelContainer(for: ApplicationRecord.self, inMemory: true)
}
