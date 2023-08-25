//
//  CopyPopupOverlayView.swift
//  LocalPass
//
//  Created by Reuben on 25/08/2023.
//

import SwiftUI

struct CopyPopupOverlayView: View {
    
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: accountsViewModel.showCopyPopupOverlay ? 55 : 15)
            
            ZStack {
                Capsule()
                  
                HStack(alignment: .center) {
                    Text("Copied")
                        .foregroundColor(.primary.opacity(accountsViewModel.showCopyPopupOverlay ? 1 : 0))
                        .font(.headline)
                }
            }
            .frame(width: accountsViewModel.showCopyPopupOverlay ? 175 : 100, height: accountsViewModel.showCopyPopupOverlay ? 50 : 20)
            .background(Color("AccentColor").opacity(accountsViewModel.showCopyPopupOverlay ? 1 : 0))
            .foregroundStyle(.ultraThickMaterial.opacity(accountsViewModel.showCopyPopupOverlay ? 1 : 0))
            .cornerRadius(44)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
}

struct CopyPopupOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        
        CopyPopupOverlayView()
            .environmentObject(accountsViewModel)
    }
}
