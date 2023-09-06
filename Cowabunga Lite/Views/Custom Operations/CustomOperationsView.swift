//
//  CustomOperationsView.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct CustomOperationsView: View {
//    @State private var enableTweak = false
    @StateObject private var dataSingleton = DataSingleton.shared
    
    @StateObject var operationsManager = CustomOperationsManager.shared
    @Binding var viewType: Int
    @Binding var currentOperation: AdvancedObject
    
    @State var showPicker: Bool = false
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "pencil.and.outline")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Custom Operations")
                                .bold()
                            BetaTag()
                            Spacer()
                        }
//                        HStack {
//                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
//                                DataSingleton.shared.setTweakEnabled(.operations, isEnabled: nv)
//                            }).onAppear(perform: {
//                                enableTweak = DataSingleton.shared.isTweakEnabled(.operations)
//                            })
//                            Spacer()
//                        }
                    }
                }
                Divider()
                
                HStack {
                    Spacer()
                    
                    NiceButton(text: AnyView(
                        Image(systemName: "square.and.arrow.down")
                            .frame(maxWidth: 20)
                    ), action: {
                        showPicker = true
                    })
                    .padding(.horizontal, 5)
                    .fileImporter(
                        isPresented: $showPicker,
                        allowedContentTypes: [
                            UTType(filenameExtension: "cowperation") ?? .zip
                        ],
                        allowsMultipleSelection: true,
                        onCompletion: { result in
                            guard let urls = try? result.get() else { return }
                            for url in urls {
                                do {
                                    try operationsManager.importOperation(url)
                                } catch {
                                    Logger.shared.logMe(error.localizedDescription)
                                }
                            }
                            // update operations
                            operationsManager.getOperations()
                        }
                    )
                    
                    NiceButton(text: AnyView(
                        Image(systemName: "plus")
                            .frame(maxWidth: 20)
                    ), action: {
                        do {
                            currentOperation = try operationsManager.createOperation()
                            viewType = 1
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                    .padding(.horizontal, 5)
                }
                
                ForEach(operationsManager.operations) { operation in
                    HStack {
                        Text(operation.name)
                            .bold()
                            .padding(.leading, 15)
                        Text("v\(operation.version)")
                            .font(.footnote)
                            .opacity(0.8)
                            .padding(.horizontal, 8)
                        if (operation.enabled) {
                            Image(systemName: "checkmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10, height: 10)
                        }
                        Spacer()
                        
                        // edit button
                        NiceButton(text: AnyView(
                            Image(systemName: "square.and.pencil")
                                .frame(maxWidth: 20)
                        ), action: {
                            currentOperation = operation
                            viewType = 1
                        })
                        .padding(.vertical, 2)
                        
                        // delete button
                        NiceButton(text: AnyView(
                            Image(systemName: "trash.fill")
                                .frame(maxWidth: 20)
                                .foregroundColor(.red)
                        ), action: {
                            operationsManager.deleteOperation(name: operation.name)
                        })
                        .padding(.trailing, 7)
                        .padding(.vertical, 2)
                    }
                    .background(Color.cowGray)
                    .cornerRadius(8)
                }
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}
