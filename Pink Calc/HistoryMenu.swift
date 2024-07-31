//
//  HistoryMenu.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-31.
//

import SwiftUI

struct HistoryMenu: View {
    var history: [String : String]
    
    var body: some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(Color.gray.opacity(0.5))
            .padding(.top, 8)
            
            Spacer()
            
            List {
                ForEach(history.keys.sorted(), id: \.self) { key in
                    VStack(alignment: .leading) {
                        Text(key)
                        Text("= \(history[key] ?? "Error")")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryMenu(history: ["1+1": "2", "2+2": "4", "3+3": "6"])
}
