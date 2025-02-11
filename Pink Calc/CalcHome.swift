//
//  CalcHome.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-07-29.
//

import SwiftUI
import Foundation
import Expression

// Override Apple's Expression with NumericExpression locally
typealias Expression = NumericExpression

struct CalcHome: View {
    @State var displayText: String = "0"
    @State var typing: Bool = false
    @State var equalPressed: Bool = false
    @State var history: [(String, String)] = []
    @State var historyMenu: Bool = false
    @State private var selectedPart: (Int, String)? = nil
    @State private var editingPart: String = ""
    @State private var scrollToEnd: Bool = false
    @State var layoutType: layouts = .standard
    var editingMode: Bool {
        return selectedPart != nil
    }
    
    var resultText: String {
        calculate()
    }
    
    private var btnLayoutHeightRatio: CGFloat {
        switch layoutType {
        case .standard:
            return 0.6
        case .expanded:
            return 0.7
        }
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
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(splitExpression(displayText), id: \.0) { index, part in
                                DisplayTextPart(
                                    isSelected: Binding (
                                        get: { self.selectedPart?.0 == index },
                                        set: { isSelected in
                                            self.editingPart = ""
                                            if isSelected {
                                                self.selectedPart = (index, part)
                                            } else {
                                                self.selectedPart = nil
                                            }
                                        }
                                    ),
                                    part: part,
                                    equalPressed: $equalPressed
                                )
                                .textSelection(.enabled)
                            }
                            
                        }
                        .environment(\.layoutDirection, .leftToRight)
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    HStack {
                        Spacer()
                        Text("= " + resultText)
                            .font(equalPressed ? .system(size: 90) : .system(size: 45))
                            .animation(.easeInOut, value: equalPressed)
                            .textSelection(.enabled)
                    }
                }
                .padding()
                
                BtnLayout(action: pressKey, longAction: longPressKey, editingMode: .constant(editingMode), layoutType: $layoutType)
                    .frame(width: geometry.size.width, height: geometry.size.height * btnLayoutHeightRatio)
//                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    func closeParaReady() -> Bool {
        if displayText.filter({ $0 == "(" }).count > displayText.filter({ $0 == ")" }).count {
            return true
        } else {
            return false
        }
    }
    
    func replaceSelectedPart(with label: String, assign: String? = nil) {
        displayText = displayText.replacingOccurrences(of: selectedPart!.1, with: label, options: .literal, range: displayText.range(of: selectedPart!.1))
        
        switch assign {
        case "none":
            break
        case nil:
            selectedPart!.1 = label
        default:
            selectedPart!.1 = assign!
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
            if !(displayText.last.map { "+-×÷.".contains($0) } ?? false) {
                if !editingMode {
                    displayText += label
                } else {
                    replaceSelectedPart(with: label)
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
        case "B":
            if displayText.count == 1 {
                displayText = "0"
            } else if selectedPart != nil {
                replaceSelectedPart(with: String(selectedPart!.1.dropLast()), assign: "none")
            } else if typing {
                displayText.removeLast()
            }
        case "=":
            typing = false
        case ".":
            if !editingMode {
                let operators: Set<Character> = ["+", "-", "×", "÷", "("]
                let components = displayText.split(whereSeparator: { operators.contains($0) })
                if (displayText.last.map { operators.contains($0) } ?? false) {
                    displayText += "0\(label)"
                } else if !(displayText.last.map { $0 == "." } ?? false) && !components.last!.contains(".") {
                    displayText += label
                }
            } else {
                replaceSelectedPart(with: selectedPart!.1+label)
                editingPart = selectedPart!.1
            }
        case "S":
            layoutType == .standard ? (layoutType = .expanded) : (layoutType = .standard)
        case "(":
            if !editingMode {
                displayText += label
            } else if editingPart.isEmpty {
                replaceSelectedPart(with: label)
                editingPart = label
            } else {
                editingPart += label
                replaceSelectedPart(with: editingPart)
            }
        case ")":
            if closeParaReady() {
                if !editingMode {
                    displayText += label
                } else if editingPart.isEmpty {
                    replaceSelectedPart(with: label)
                    editingPart = label
                } else {
                    editingPart += label
                    replaceSelectedPart(with: editingPart)
                }
            }
        default:
            if displayText != "0" {
                if !editingMode {
                    displayText += label
                } else if editingPart.isEmpty {
                    replaceSelectedPart(with: label)
                    editingPart = label
                } else {
                    editingPart += label
                    replaceSelectedPart(with: editingPart)
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
    
    func fixUpExpression(_ expression: String) -> String {
        var validExpression = expression
        
        // Remove ( just beofre an operator
        let paraOpRegex = try! NSRegularExpression(pattern: "\\((?=[+\\-*/])", options: [])
        let paraOpRange = NSRange(location: 0, length: validExpression.utf16.count)
        validExpression = paraOpRegex.stringByReplacingMatches(in: validExpression, options: [], range: paraOpRange, withTemplate: "")
        
        // Removes ()
        validExpression = validExpression.replacingOccurrences(of: "()", with: "")
        
        if let lastChar = validExpression.last {
            if "+-*/.".contains(lastChar) {
                // Remove the last character if it's an operator or a period
                validExpression.removeLast()
            } else if lastChar == "(" {
                // Remove the last character if it's an open paranthesis
                validExpression.removeLast()
                if let newLastChar = validExpression.last, "+-*/.".contains(newLastChar) {
                    // Remove the new last character if it's an operator or a period
                    validExpression.removeLast()
                }
            }
        }
        
        // Replace ( with *( where appropriate
        let paraMultiRegex = try! NSRegularExpression(pattern: "(?<=\\d)\\(", options: [])
        let paraMultiRange = NSRange(location: 0, length: validExpression.utf16.count)
        validExpression = paraMultiRegex.stringByReplacingMatches(in: validExpression, options: [], range: paraMultiRange, withTemplate: "*(")
        
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
        
        // Auto complete open parantheses
        let openParaCount = validExpression.filter { $0 == "(" }.count
        let closeParaCount = validExpression.filter { $0 == ")" }.count
        validExpression.append(String(repeating: ")", count: openParaCount-closeParaCount))
        
        // Remove invalid decimal points
        let decRegex = try! NSRegularExpression(pattern: "\\.(?=[\\+\\-\\/\\*\\(\\)])", options: [])
        let decRange = NSRange(location: 0, length: validExpression.utf16.count)
        validExpression = decRegex.stringByReplacingMatches(in: validExpression, options: [], range: decRange, withTemplate: "")
        
        if let lastChar = validExpression.last {
            if "+-*/.".contains(lastChar) {
                // Remove the last character if it's an operator or a period
                validExpression.removeLast()
            } else if lastChar == "(" {
                // Remove the last character if it's an open paranthesis
                validExpression.removeLast()
                if let newLastChar = validExpression.last, "+-*/.".contains(newLastChar) {
                    // Remove the new last character if it's an operator or a period
                    validExpression.removeLast()
                }
            }
        }
        
        // Add 1 after * and before )
        validExpression = validExpression.replacingOccurrences(of: "*)", with: "*1)")
        
        return validExpression
    }
    
    func calculate() -> String {
        // Handle zero division
        if displayText.contains("÷0") {
            return "Can't divide by zero"
        } else {
            // Replace visual symbols with math symbols
            var validExpression = displayText
                .replacingOccurrences(of: "×", with: "*")
                .replacingOccurrences(of: "÷", with: "/")
        
            // Fix up expression
            validExpression = fixUpExpression(validExpression)
            
            // Convert expression to Expression
            print(validExpression)
            let expression = Expression(validExpression)
            // Handle invalid Expressions and evaluate
            do {
                let result = try expression.evaluate()
                // Display int as int
                if result.truncatingRemainder(dividingBy: 1) == 0 {
                    return "\(Int(result))"
                } else {
                    return "\(result)"
                }
            } catch {
                return "Error"
            }
        }
    }
    
    func splitExpression(_ expression: String) -> [(Int, String)] {
        let regex = try! NSRegularExpression(pattern: "\\d+(\\.\\d*)?|[+\\-×÷()]+") // Doesn't split the period symbol
//        let regex = try! NSRegularExpression(pattern: "\\d+|[+\\-×÷.]|[()]") // Split period symbol too
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
