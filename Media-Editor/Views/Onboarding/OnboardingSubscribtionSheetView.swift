//
//  OnboardingSubscribtionSheetView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/06/2024.
//

import SwiftUI

struct OnboardingSubscribtionSheetView: View {
    @EnvironmentObject var vm: OnboardingViewModel
    @State var isToggled = false

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 16.0) {
                Text("Choose your plan")
                    .font(.init(.custom("Kaushan Script", size: 24)))
                OnboardingSubscribtionSheetCapsuleView(circleText: "-30%", upperText: "One year",
                                                       lowerText: vm.isFreeTrialToggled ? "3-day trial included" : "Best value",
                                                       price: " 49.99$", duration: "1 y")
                    .modifier(CapsuleBorderStroke(isEnabled: vm.subscribtionTypeSelected == .oneYear))
                    .onTapGesture {
                        vm.isSubscriptionFullscreenShown = true
                        vm.subscribtionTypeSelected = SubscriptionType.oneYear
                    }
                OnboardingSubscribtionSheetCapsuleView(circleText: "-10%", upperText: "One month",
                                                       lowerText: vm.isFreeTrialToggled ? "3-day trial included" : "Most popular",
                                                       price: "4.99$", duration: "1 mo")
                    .modifier(CapsuleBorderStroke(isEnabled: vm.subscribtionTypeSelected == .oneMonth))
                    .onTapGesture {
                        vm.isSubscriptionFullscreenShown = true
                        vm.subscribtionTypeSelected = SubscriptionType.oneMonth
                    }
                HStack {
                    Spacer()
                    OnboardingSubscribtionTrialToggleView()
                    Spacer()
                }

                if vm.isSubscriptionFullscreenShown {
                    Text("""
                    You may purchase an auto-renewing subscription through an In-App Purchase.
                    • Upon subscribing, you will receive immediate access to all app functionalities.
                    • Auto-renewable subscription
                    • 1 month ($4.99) and 1 year ($49.99) durations
                    • Your subscription will be charged to your iTunes account at confirmation of purchase and will automatically renew (at the duration selected) unless auto-renew is turned off at least 24 hours before the end of the current period.
                    • Current subscription may not be cancelled during the active subscription period; however, you can manage your subscription and/or turn off auto-renewal by visiting your iTunes Account Settings after purchase
                    • Privacy policy and terms of use:
                    https://lukaszbielawski8.wordpress.com/2024/04/20/privacy-policy/
                    """)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
                    .transition(.normalOpacityTransition)
                    Button("Get started") {
                        Task {
                            await vm.showSubscribtionSheet()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .animation(.easeInOut(duration: 0.35), value: vm.subscribtionTypeSelected)
                    .disabled(vm.subscribtionTypeSelected == .none)
                }
                Spacer()
            }
            .padding(.top, 16.0)
            .padding(.horizontal, 16.0)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            vm.isSubscriptionFullscreenShown = true
        }
        .background(Color(.background))
        .roundedUpperCorners(16.0)
        .animation(.easeInOut(duration: 0.35), value: vm.isSheetPresented)
        .animation(.easeInOut(duration: 0.35), value: vm.isSubscriptionFullscreenShown)
        .padding(.vertical, vm.isSubscriptionFullscreenShown ? 0.0 : UIScreen.bottomSafeArea)
        .frame(maxHeight: vm.isSubscriptionFullscreenShown
            ? .infinity
            : vm.sheetHeight)
        .offset(y: vm.isSheetPresented ? 0 : vm.sheetHeight)
    }
}

struct OnboardingSubscribtionSheetCapsuleView: View {
    let circleText: String
    let upperText: String
    let lowerText: String
    let price: String
    let duration: String

    let height: CGFloat = 60.0

    var body: some View {
        Capsule(style: .circular)
            .fill(Color(.white))
            .shadow(radius: 8.0)
            .blendMode(.destinationOut)
            .frame(height: height)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(Color(.secondary))
                Text(circleText)
                    .bold()
                    .foregroundStyle(Color(.secondaryTint))
            }
            .overlay(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(upperText)
                            .font(.title3)
                        Text(lowerText)
                            .font(.caption)
                    }
                    Spacer()
                    VStack {
                        Text(price)
                            .font(.title3)
                        Text(duration)
                            .font(.caption)
                    }
                    .padding(.trailing, 16.0)
                }
                .foregroundStyle(Color(.tint))
                .padding(.leading, height + 16.0)
            }
    }
}

struct OnboardingSubscribtionTrialToggleView: View {
    @EnvironmentObject var vm: OnboardingViewModel

    var body: some View {
        HStack {
            Spacer()
            Text("Get a free 3-day trial")
            Toggle(isOn: $vm.isFreeTrialToggled) {
                EmptyView()
            }
            .labelsHidden()
            Spacer()
        }
    }
}
