//
//  AccountDetailView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @ObservedObject var vm: SettingsViewModel
    
    var body: some View {
        ScrollView {
            personaView()
            Button("Logout", role: .destructive) {
                loginVM.logout()
            }
        }
            // TODO: Future enhancement
//            List {
//                personaView()
//                NavigationLink {
//                    Button("Logout", role: .destructive) {
//                        loginVM.logout()
//                    }
//                } label: {
//                    SettingsCellView(
//                        text: "Account",
//                        iconName: "person",
//                        color: .green
//                    )
//                }
//                SettingsCellView(
//                    text: "Appearance",
//                    iconName: "sun.max",
//                    color: .orange
//                )
//                SettingsCellView(
//                    text: "Notifications",
//                    iconName: "bell",
//                    color: .red
//                )
//                SettingsCellView(
//                    text: "Privacy",
//                    iconName: "lock.shield",
//                    color: .blue
//                )
//            }
    }
    
    func personaView() -> some View {
        ZStack {
            Image(uiImage: vm.profileThimbnail())
                .resizable()
                .frame(height: 150)
                .clipShape(Ellipse())
                .blur(radius: 30)
                .opacity(0.5)
            
            VStack {
                AvatarView(model: AvatarModel(tdImage: vm.user?.profilePhoto))
                    .frame(width: 50, height: 50)
                Text(vm.user?.fullName ?? "")
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                Text(vm.user?.mainUserName ?? "")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(vm.user?.phoneNumber ?? "")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 120)
        .listItemTint(.black)
        .offset(y: -10)
    }
}

#Preview {
    AccountDetailView(vm: MockSettingsViewModel())
        .environmentObject(LoginViewModel())
}
