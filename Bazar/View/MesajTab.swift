//
//  MesajTab.swift
//  Bazar
//
//  Created by Emre Şahin on 14.01.2025.
//

import SwiftUI


struct MesajTab: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isSignedIn {
            MessajlarView()
        } else {
            AuthView()
        }
    }
}
