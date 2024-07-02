//
//  OnboardingTabView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/06/2024.
//

import SwiftUI

struct OnboardingTabView: View {
    @EnvironmentObject var vm: OnboardingViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            if vm.currentTab == .title {
                OnboardingTabTitleView()
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 16)
                            .onChanged { _ in
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    vm.currentTab = .basic
                                }
                            })
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            vm.currentTab = .basic
                        }
                    }
            } else {
                TabView(selection: $vm.currentTab) {
                    ForEach(OnboardingTabType.allCases, id: \.self) { tabType in
                        tabType.associatedView
                            .tag(tabType)
                            .onTapGesture {
                                if let nextTab = tabType.next() {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        vm.currentTab = nextTab
                                    }
                                }
                            }
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: vm.isSheetPresented)
                .padding(.bottom, vm.isSheetPresented ? vm.sheetHeight : 16.0)
            }
            OnboardingSubscribtionSheetView()
                .frame(height: vm.sheetHeight)
                .background(Color(.background))
                .roundedUpperCorners(16.0)
                .compositingGroup()
                .animation(.easeInOut(duration: 0.35), value: vm.isSheetPresented)
                .offset(y: vm.isSheetPresented ? 0 : vm.sheetHeight)
        }
        .background(Image("MenuBackground"))
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingTabView()
        .environmentObject(OnboardingViewModel())
}
