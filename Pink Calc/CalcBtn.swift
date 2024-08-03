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
    let longAction: (String) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    @State private var placeholder: Bool = false //TODO: Change the placeholder
    
    let operators: Set<Character> = ["÷", "×", "-", "+", "=", "T"]
    let topOp: Set<String> = ["(", ")", "B"]
    
    let hotpink: Color = Color(red: 1, green: 105/255, blue: 180/255)
    
    var bgColor: Color {
        switch label {
        case _ where topOp.contains(label):
            return (colorScheme == .light ? Color(UIColor.systemGray5) : Color(UIColor.systemGray))
        case _ where operators.contains(label):
            return hotpink
        default:
            return Color(UIColor.systemGray6)
        }
    }
    
    var fgColor: Color {
        switch label {
        case _ where operators.contains(label):
            return .white
        case _ where topOp.contains(label):
            return .black
        case "S":
            return hotpink
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
            } else if label == "T" {
                Image(systemName: "checkmark")
                    .font(.system(size: 25))
                    .frame(width: 79, height: 79)
                    .foregroundColor(bgColor)
                    .background(fgColor)
                    .cornerRadius(100)
            } else if label == "S" {
                Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                    .font(.system(size: 25))
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
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 1)
                .onEnded { _ in
                    longAction(label)
                }
        )
        .contextMenu {
            if label == "S" {
                Button(action: {action(label)}) { // TODO: Change the action
                    Label("Basic", systemImage: "plus.forwardslash.minus")
                }
                Button(action: {action(label)}) { // TODO: Change the action
                    Label("Scientific", systemImage: "function")
                }
                Button(action: {action(label)}) { // TODO: Change the action
                    Label("Programming", systemImage: "macbook")
                }
                Toggle("Convert", systemImage: "arrow.triangle.2.circlepath", isOn: $placeholder)
            }
        }
    }
}

#Preview {
    CalcBtn(label: "S", action: {_ in}, longAction: {_ in})
}
