//
//  BtnLayout.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-29.
//

import SwiftUI

struct BtnLayout: View {
    let action: (String) -> Void
    let longAction: (String) -> Void
    @Binding var editingMode: Bool
    
    var equalText: String {
        return editingMode ? "T" : "="
    }
    
    var body: some View {
        let labels = [
            ["B", "(", ")", "÷"],
                ["7", "8", "9", "×"],
                ["4", "5", "6", "-"],
                ["1", "2", "3", "+"],
                ["S", "0", ".", equalText]
            ]
        
        GeometryReader { geometry in
            let horizontalSpacing: CGFloat = (geometry.size.width - CGFloat(79 * labels[0].count)) / CGFloat(labels[0].count + 1)
            let verticalSpacing: CGFloat = (geometry.size.height - CGFloat(79 * labels.count)) / CGFloat(labels.count - 1)
            
            VStack(spacing: verticalSpacing) {
                ForEach(0..<labels.count, id: \.self) { row in
                    HStack(spacing: horizontalSpacing) {
                        ForEach(0..<labels[0].count, id: \.self) { column in
                            let label = labels[row][column]
                            CalcBtn(label: label, action: action, longAction: longAction)
                        }
                    }
                    .padding(.leading, horizontalSpacing)
                    .padding(.trailing, horizontalSpacing)
                }
            }
        }
    }
}

//#Preview {
//    BtnLayout(action: { _ in }, longAction: { _ in}, selectedPart: .constant(nil))
//}
