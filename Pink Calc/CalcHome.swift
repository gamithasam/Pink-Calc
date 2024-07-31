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
    @State var equalPressed: Bool = false
    
    
    var resultText: String {
        calculate()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                }
                .padding(.trailing)
                
                Spacer()
                
                VStack {
                    HStack {
                        Spacer()
                        Text(displayText)
                            .font(equalPressed ? .system(size: 45) : .system(size: 90))
                            .animation(.easeInOut, value: equalPressed)
                    }
                    HStack {
                        Spacer()
                        Text("= " + resultText)
                            .font(equalPressed ? .system(size: 90) : .system(size: 45))
                            .animation(.easeInOut, value: equalPressed)
                    }
                }
                .padding()
                
                BtnLayout(action: pressKey, clearLabel: typing ? "C" : "AC")
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    func pressKey(label: String) {
        if label == "=" {
            withAnimation {
                equalPressed = true
            }
        } else {
            if equalPressed {
                displayText = resultText
            }
            withAnimation {
                equalPressed = false
            }
        }
        
        switch label {
        case "+", "-", "×", "÷":
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
            if typing {
                displayText = String(displayText.dropLast())
            }
        case "=":
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
    
    func calculate() -> String {
        // Handle zero division
        if displayText.contains("/0") {
            return "Can't divide by zero"
        } else {
            // Handle expressions with operators at last
            var validExpression = displayText
            if let lastChar = validExpression.last, "+-×÷".contains(lastChar) {
                validExpression.removeLast()
            }
            // Convert expression to NSExpression
            let expression = NSExpression(format: validExpression)
            // Handle invalid NSExpressions
            if let result = expression.expressionValue(with: nil, context: nil) as? Double {
                // Display int as int
                if result.truncatingRemainder(dividingBy: 1) == 0 {
                    return "\(Int(result))"
                } else {
                    return "\(result)"
                }
            } else {
                return "Error"
            }
        }
    }
}

#Preview {
    CalcHome()
}
