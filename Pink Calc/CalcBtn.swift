//
//  CalcBtn.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-29.
//

import SwiftUI

struct CalcBtn: View {
    let label: String
    let action: (String) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var bgColor: Color {
        switch label {
        case "AC", "C", "B", "%":
            return (colorScheme == .light ? Color(UIColor.systemGray5) : Color(UIColor.systemGray))
            
        case "÷", "×", "-", "+", "=":
            let cGreen: Double = 105/255
            let cBlue: Double = 180/255
            return Color(red: 1, green: cGreen, blue: cBlue)
        default:
            return Color(UIColor.systemGray6)
        }
    }
    
    var fgColor: Color {
        let operators: Set<Character> = ["÷", "×", "-", "+", "="]
        let topOp: Set<String> = ["AC", "C", "B", "%"]
        
        switch label {
        case _ where operators.contains(label):
            return .white
        case _ where topOp.contains(label):
            return .black
        default:
            return .primary
        }
    }
    
    var body: some View {
        Button (action: {action(label)}) {
            if label == "B" {
                Image(systemName: "delete.backward")
                    .font(.system(size: 35))
                    .frame(width: 79, height: 79)
                    .foregroundColor(fgColor)
                    .background(bgColor)
                    .cornerRadius(100)
            } else {
                Text(label)
                    .font(.system(size: 40))
                    .frame(width: 79, height: 79)
                    .foregroundColor(fgColor)
                    .background(bgColor)
                    .cornerRadius(100)
            }
        }
    }
}

#Preview {
    CalcBtn(label: "÷", action: {_ in})
}
