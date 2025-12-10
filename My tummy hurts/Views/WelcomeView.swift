//
//  WelcomeView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 26/02/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isOnboarding: Bool
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    
    var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            TabView {
                LogoIntroductionView()
                InputDataView()
                BePrecise()
                TopIngredients()
                SpecificSymptom()
                MonthlyCalendar()
                Info(isOnboarding: $isOnboarding)
            }
            .tabViewStyle(PageTabViewStyle())
            .tintedTabViewStyle()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Onboarding") {
    NavigationStack {
        WelcomeView(isOnboarding: .constant(true))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        //            .toolbar {
        //                ToolbarItem(placement: .topBarTrailing) {
        //                    Button {} label: {
        //                        Text("Skip")
        //                            .font(.body)
        //                            .foregroundColor(.accent)
        //                    }
        //                }
        //            }
        //            .toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
        //            .toolbarBackground(.visible, for: .navigationBar)
        //            .background(Color("BackgroundColor").ignoresSafeArea())
    }
    //    .environment(\.colorScheme, .dark)
    .environment(\.colorScheme, .light)
}

extension View {
    func tintedTabViewStyle(_ pageTabViewStyle: PageTabViewStyle = .page, color: Color = .accentColor) -> some View {
        self.modifier(TintedPageViewTabStyleModifier(pageTabViewStyle: pageTabViewStyle, color: color))
    }
}

struct TintedPageViewTabStyleModifier: ViewModifier {
    var pageTabViewStyle: PageTabViewStyle
    var color: Color
    
    @State private var originalCurrentPageIndicatorTintColor: UIColor?
    @State private var originalPageIndicatorTintColor: UIColor?
    
    func body(content: Content) -> some View {
        content
            .tabViewStyle(pageTabViewStyle)
            .onAppear {
                let appearance = UIPageControl.appearance()
                originalCurrentPageIndicatorTintColor = appearance.currentPageIndicatorTintColor
                originalPageIndicatorTintColor = appearance.pageIndicatorTintColor
                
                appearance.currentPageIndicatorTintColor = UIColor(color)
                appearance.pageIndicatorTintColor = UIColor(color.opacity(0.2))
            }
            .onDisappear {
                guard let originalCurrentPageIndicatorTintColor,
                      let originalPageIndicatorTintColor else { return }
                let appearance = UIPageControl.appearance()
                appearance.currentPageIndicatorTintColor = originalCurrentPageIndicatorTintColor
                appearance.pageIndicatorTintColor = originalPageIndicatorTintColor
            }
    }
}
