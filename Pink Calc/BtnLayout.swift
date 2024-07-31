//
//  BtnLayout.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-29.
//

import SwiftUI

struct BtnLayout: View {
    let action: (String) -> Void
    let clearLabel: String
    
    var body: some View {
        let labels = [
            [clearLabel, "B", "%", "÷"],
                ["7", "8", "9", "×"],
                ["4", "5", "6", "-"],
                ["1", "2", "3", "+"],
                ["00", "0", ".", "="]
            ]
        
        GeometryReader { geometry in
            let horizontalSpacing: CGFloat = (geometry.size.width - CGFloat(79 * labels[0].count)) / CGFloat(labels[0].count + 1)
            let verticalSpacing: CGFloat = (geometry.size.height - CGFloat(79 * labels.count)) / CGFloat(labels.count - 1)
            
            VStack(spacing: verticalSpacing) {
                ForEach(0..<labels.count, id: \.self) { row in
                    HStack(spacing: horizontalSpacing) {
                        ForEach(0..<labels[0].count, id: \.self) { column in
                            let label = labels[row][column]
                            CalcBtn(label: label, action: action)
                        }
                    }
                    .padding(.leading, horizontalSpacing)
                    .padding(.trailing, horizontalSpacing)
                }
            }
        }
    }
}

#Preview {
    BtnLayout(action: { _ in }, clearLabel: "AC")
}
