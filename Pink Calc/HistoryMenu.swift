//
//  HistoryMenu.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-31.
//

import SwiftUI

struct HistoryMenu: View {
    @State var history: [(String, String)]
    @Binding var displayText: String
    @Binding var typing: Bool
    @Binding var equalPressed: Bool
    @Binding var historyMenu: Bool
    
    var body: some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(Color.gray.opacity(0.5))
            .padding(.top, 8)
            
            Spacer()
            
            List {
                ForEach(history.reversed(), id: \.0) { (key, value) in
                    VStack(alignment: .leading) {
                        Text(key)
                        Text("= \(value)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        displayText = key
                        typing = true
                        equalPressed = false
                        historyMenu = false
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                history = []
            }) {
                Text("Clear History")
            }
        }
    }
}

//#Preview {
//    HistoryMenu(history: ["1+1": "2", "2+2": "4", "3+3": "6"])
//}
