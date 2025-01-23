//
//  IlanTab.swift
//  Bazar
//
//  Created by Emre Şahin on 14.01.2025.
//

import SwiftUI


struct IlanTab: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isSignedIn {
            ilanBilgiGirisi()
        } else {
            AuthView()
        }
    }
}
