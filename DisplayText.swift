//
//  DisplayText.swift
//  Pink Calc
//
//  Created by Gamitha Samarasingha on 2024-08-01.
//

import SwiftUI

struct DisplayText: View {
    @Binding var isSelected: Bool
    let part: String
    @Binding var equalPressed: Bool
    
    var body: some View {
        let cGreen: Double = 105/255
        let cBlue: Double = 180/255
        let hotpink = Color(red: 1, green: cGreen, blue: cBlue)
        
        Text(part)
            .font(equalPressed ? .system(size: 45) : .system(size: 90))
            .animation(.easeInOut, value: equalPressed)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(hotpink, lineWidth: 2)
                    .opacity(isSelected ? 1 : 0)
            )
            .onTapGesture {
                isSelected.toggle()
            }
    }
}

//#Preview {
//    DisplayText(part: "250", equalPressed: )
//}
