//
//  CalcHome.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-29.
//

import SwiftUI
import Foundation

struct CalcHome: View {
    @State var displayText: String = "0"
    @State var typing: Bool = false
    @State var equalPressed: Bool = false
    @State var history: [(String, String)] = []
    @State var historyMenu: Bool = false
    @State private var selectedPart: (Int, String)? = nil
    @State private var editingPart: String = ""
    @State var editingMode: Bool = false
    
    var resultText: String {
        calculate()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .onTapGesture {
                            historyMenu.toggle()
                        }
                }
                .sheet(isPresented: $historyMenu) {
                    HistoryMenu(history: history, displayText: $displayText, typing: $typing, equalPressed: $equalPressed, historyMenu: $historyMenu)
                }
                .padding(.trailing)
                
                Spacer()
                
                VStack {
                    HStack {
                        Spacer()
                        ForEach(splitExpression(displayText), id: \.0) { index, part in
                            DisplayTextPart(
                                isSelected: Binding (
                                    get: { self.selectedPart?.0 == index },
                                    set: { isSelected in
                                        if isSelected {
                                            self.selectedPart = (index, part)
                                            self.editingPart = ""
                                            self.editingMode = true
                                        } else {
                                            self.selectedPart = nil
                                            self.editingPart = ""
                                            self.editingMode = false
                                        }
                                    }
                                ),
                                part: part,
                                equalPressed: $equalPressed
                            )
                            .textSelection(.enabled)
                        }
                    }
                    HStack {
                        Spacer()
                        Text("= " + resultText)
                            .font(equalPressed ? .system(size: 90) : .system(size: 45))
                            .animation(.easeInOut, value: equalPressed)
                            .textSelection(.enabled)
                    }
                }
                .padding()
                
                BtnLayout(action: pressKey, longAction: longPressKey, editingMode: $editingMode)
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
            history.append((displayText, resultText))
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
            if !(displayText.last.map { "+-×÷".contains($0) } ?? false) {
                if selectedPart == nil {
                    displayText += label
                } else {
                    displayText = displayText.replacingOccurrences(of: selectedPart!.1, with: label, options: .literal, range: displayText.range(of: selectedPart!.1))
                    selectedPart!.1 = label
                }
                typing = true
            } else if !displayText.isEmpty {
                displayText.removeLast()
                displayText.append(label)
            }
        case "%":
            if let num = Double(displayText) {
                displayText = "\(num / 100)"
                typing = true
            }
        case "T":
            selectedPart = nil
            editingPart = ""
            editingMode = false
        case "B":
            if displayText.count == 1 {
                displayText = "0"
            } else if selectedPart != nil {
                displayText = displayText.replacingOccurrences(of: selectedPart!.1, with: String(selectedPart!.1.dropLast()), options: .literal, range: displayText.range(of: selectedPart!.1))
            } else if typing {
                displayText.removeLast()
            }
        case "=":
            typing = false
        case ".":
            if (displayText.last.map { "+-×÷".contains($0) } ?? false) {
                displayText += "0\(label)"
            } else {
                displayText += label
            }
        case "S":
            print("Yo")
        case "(":
            let label = "*" + label
            if selectedPart == nil {
                displayText += label
            } else {
                if editingPart.isEmpty {
                    displayText = displayText.replacingOccurrences(of: selectedPart!.1, with: label, options: .literal, range: displayText.range(of: selectedPart!.1))
                    selectedPart!.1 = label
                    editingPart = label
                } else {
                    editingPart += label
                    displayText = displayText.replacingOccurrences(of: selectedPart!.1, with: editingPart, options: .literal, range: displayText.range(of: selectedPart!.1))
                    selectedPart!.1 = editingPart
                }
            }
        default:
            if displayText != "0" {
                if selectedPart == nil {
                    displayText += label
                } else {
                    if editingPart.isEmpty {
                        displayText = displayText.replacingOccurrences(of: selectedPart!.1, with: label, options: .literal, range: displayText.range(of: selectedPart!.1))
                        selectedPart!.1 = label
                        editingPart = label
                    } else {
                        editingPart += label
                        displayText = displayText.replacingOccurrences(of: selectedPart!.1, with: editingPart, options: .literal, range: displayText.range(of: selectedPart!.1))
                        selectedPart!.1 = editingPart
                    }
                }
            } else {
                displayText = label
                typing = true
            }
        }
    }
    
    func longPressKey(label: String) {
        if label == "B" {
            displayText = "0"
            typing = false
            selectedPart = nil
        }
    }
    
    func calculate() -> String {
        // Handle zero division
        if displayText.contains("÷0") {
            return "Can't divide by zero"
        } else {
            // Handle expressions with operators at last
            var validExpression = displayText
                .replacingOccurrences(of: "×", with: "*")
                .replacingOccurrences(of: "÷", with: "/")
            if let lastChar = validExpression.last, "+-*/.".contains(lastChar) {
                validExpression.removeLast()
            } else if let lastChar = validExpression.last, "(".contains(lastChar) {
                validExpression.removeLast()
                validExpression.removeLast()
            }
            
            // Remove extra closing parantheses
            var paraBalancedExpression = ""
            var openCount = 0
            for char in validExpression {
                if char == "(" {
                    openCount += 1
                    paraBalancedExpression.append(char)
                } else if char == ")" {
                    if openCount > 0 {
                        openCount -= 1
                        paraBalancedExpression.append(char)
                    }
                } else {
                    paraBalancedExpression.append(char)
                }
            }
            validExpression = paraBalancedExpression
            print(validExpression)
            // Auto complete open parantheses
            let openParaCount = validExpression.filter { $0 == "(" }.count
            let closeParaCount = validExpression.filter { $0 == ")" }.count
            validExpression.append(String(repeating: ")", count: openParaCount-closeParaCount))
            
            
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
    
    func splitExpression(_ expression: String) -> [(Int, String)] {
        let regex = try! NSRegularExpression(pattern: "\\d+|[+\\-×÷.]|[()]")
        let matches = regex.matches(in: expression, range: NSRange(expression.startIndex..., in: expression))
        let numbers = matches.enumerated().map { (index, match) -> (Int, String) in
            let range = Range(match.range, in: expression)!
            return (index, String(expression[range]))
        }
        return numbers
    }
}

#Preview {
    CalcHome()
}
