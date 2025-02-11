//
//  BtnLayout.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-29.
//

import SwiftUI

enum layouts: String {
    case standard
    case expanded
}

struct BtnLayout: View {
    let action: (String) -> Void
    let longAction: (String) -> Void
    @Binding var editingMode: Bool
    @Binding var layoutType: layouts
    
    var equalText: String {
        return editingMode ? "T" : "="
    }
    
    // Standard 5x4 layout
    let standardLabels = [
        ["B", "(", ")", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["S", "0", ".", "="]
    ]
    
    // Expanded 7x5 layout
    let expandedLabels = [
        ["2nd", "deg", "sin", "cos", "tan"],
        ["xʸ", "lg", "ln", "x", "y"],
        ["√x", "B", "(", ")", "÷"],
        ["x!", "7", "8", "9", "×"],
        ["1/x", "4", "5", "6", "-"],
        ["π", "1", "2", "3", "+"],
        ["S", "e", "0", ".", "="]
    ]
    
    var currentLabels: [[String]] {
        layoutType == .standard ? standardLabels : expandedLabels
    }
    
    var body: some View {
        GeometryReader { geometry in
            let columnCount = currentLabels[0].count
            let rowCount = currentLabels.count
            
            // Calculate button size based on available space
            let buttonWidth = min(
                (geometry.size.width * 0.85) / CGFloat(columnCount),
                79.0
            )
            let buttonHeight = min(
                (geometry.size.height * 0.85) / CGFloat(rowCount),
                79.0
            )
            
            // Calculate spacing
            let horizontalSpacing = (geometry.size.width - (buttonWidth * CGFloat(columnCount))) / CGFloat(columnCount + 1)
            let verticalSpacing = (geometry.size.height - (buttonHeight * CGFloat(rowCount))) / CGFloat(rowCount + 1)
            
            VStack(spacing: verticalSpacing) {
                ForEach(0..<currentLabels.count, id: \.self) { row in
                    HStack(spacing: horizontalSpacing) {
                        ForEach(0..<currentLabels[row].count, id: \.self) { column in
                            let label = currentLabels[row][column]
                            CalcBtn(label: label, action: action, longAction: longAction, frameSize: buttonWidth)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, horizontalSpacing)
        }
    }
}

//#Preview {
//    BtnLayout(action: { _ in }, longAction: { _ in}, selectedPart: .constant(nil))
//}
