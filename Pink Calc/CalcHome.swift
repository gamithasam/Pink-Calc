//
//  CalcHome.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-29.
//

import SwiftUI

struct CalcHome: View {
    @State var displayText: String = "0"
    @State var typing: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    Text(displayText)
                        .font(.system(size: 90))
                }
                .padding()
                
                BtnLayout(action: pressKey, clearLabel: typing ? "C" : "AC")
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    func pressKey(label: String) {
        switch label {
        case "+", "-", "*", "/":
            displayText += label
            typing = true
        case "%":
            if let num = Double(displayText) {
                displayText = "\(num / 100)"
                typing = true
            }
        case "AC", "C":
            displayText = "0"
            typing = false
        case "B":
            displayText = String(displayText.dropLast())
        case "=":
            let expression = NSExpression(format: displayText)
            if let result = expression.expressionValue(with: nil, context: nil) as? Double {
                if result.truncatingRemainder(dividingBy: 1) == 0 {
                    displayText = "\(Int(result))"
                } else {
                    displayText = "\(result)"
                }
            }
            typing = false
        default:
            if displayText != "0" {
                displayText += label
            } else {
                displayText = label
                typing = true
            }
        }
    }
}

#Preview {
    CalcHome()
}
