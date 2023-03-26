//
//  ThemingView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/24/23.
//

import SwiftUI

struct ThemingView: View {
    @State private var enableTweak = false
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var themeManager = ThemingManager.shared
    @State private var easterEgg: Bool = false
    private var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "gear.badge.xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Icon Theming")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.themes, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.themes)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
            }
            if dataSingleton.deviceAvailable {
                Group {
                    if (themeManager.themes.count == 0) {
                        Text("No themes found. Download themes in the Explore tab,\nor import them using the button in the top right corner (Themes have to contain icons in the format of <id>.png).")
                            .padding()
                            .background(Color(.secondaryLabelColor))
                            .multilineTextAlignment(.center)
                            .cornerRadius(16)
                            .font(.footnote)
                            .foregroundColor(Color(.secondaryLabelColor))
                    } else {
                        ScrollView {
                            LazyVGrid(columns: gridItemLayout, spacing: 8) {
                                ForEach(themeManager.themes, id: \.name) { theme in
                                    ThemeView(theme: theme)
                                }
                            }
                            .padding()
                            
                            VStack {
                                HStack {
                                    VStack {
                                        Text(easterEgg ? "Wait, it's all TrollTools?" : "Cowabunga \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                                            .multilineTextAlignment(.center)
                                        Text(easterEgg ? "Always has been" : "Download themes in Themes tab.")
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(10)
                                    .background(Color(.secondaryLabelColor))
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        easterEgg.toggle()
                                    }
//                                    VStack {
//                                        HStack {
//                                            Text("Alternatives")
//                                                .font(.headline)
//                                                .lineLimit(1)
//                                                .minimumScaleFactor(0.7)
//                                                .padding(4)
//
//                                            Text("· \(themeManager.iconOverrides.count)")
//                                                .font(.headline)
//                                                .foregroundColor(Color.secondary)
//                                            Spacer()
//                                        }
//                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color(.secondaryLabelColor))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.bottom, 80)
                        .padding(.horizontal)
                    }
                }.disabled(!enableTweak)
            }
        }.disabled(!dataSingleton.deviceAvailable)
            .onAppear {
                themeManager.getThemes()
            }
    }
}

struct ThemingView_Previews: PreviewProvider {
    static var previews: some View {
        ThemingView()
    }
}
