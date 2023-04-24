//
//  AltIconView.swift
//  CowabungaJailed
//
//  Created by lemin on 4/20/23.
//

import SwiftUI

struct AltIconView: View {
    @Binding var app: AppOption
    
    var body: some View {
        VStack {
            // TODO: Select whether to theme an icon, theme an icon, upload image as an icon, set name
            Group {
                Text("Icon")
                    .bold()
                // Do Not Theme Button
                // Default Icon Button
                // Other Icons From Themes
                // + Icon (Import from png)
            }
            Group {
                Text("App Display Name")
                    .bold()
                // Use Default Toggle (Grays out textbox)
                // Text box for display name
            }
        }
    }
}
