//
//  WeekIntroductionView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 10/03/2025.
//

import SwiftUI

struct LogoIntroductionView: View {
    var body: some View {
        VStack {
            LogoView()
            Text("Eat. Track.")
            HStack {
                Text("Uncover what's")
                Text("hurting")
                    .font(.myFont)
                    .foregroundStyle(Color("WhiteCustom"))
                Text("your gut")
            }
        }
        .font(.title2)
        .multilineTextAlignment(.center)
    }
}

struct LogoView: View {
    var body: some View {
        Image("AppIconPreview")
            .resizable()
            .frame(width: 100, height: 100)
    }
}

