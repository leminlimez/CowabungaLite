//
//  ProfilesView.swift
//  Cowabunga Lite
//
//  Created by BluStik on 5/17/23.
//

import SwiftUI

struct ProfilesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                        .padding(.trailing, 5)

                    Text("Warning: Requires Device to be Supervised")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding(.bottom, 20)

                VStack(spacing: 10) {
                    Text("Scan the QR code for the profile you wish to isntall")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)

                VStack(spacing: 10) {
                    Divider()
                    Text("Screen Time Remover:")
                        .font(.title2)
                        .fontWeight(.bold)

                    Image("screentime")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                    Divider()
                }
            }
            .padding(30)
            .frame(maxWidth: .infinity)
        }
    }
}

struct ProfilesView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilesView()
    }
}
