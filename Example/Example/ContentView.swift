//
//  ContentView.swift
//  Example
//
//  Created by Macbook on 22/4/26.
//

import SwiftUI
import DEToolkit

struct ContentView: View {
    @StateObject var storage = UserDefaultManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
