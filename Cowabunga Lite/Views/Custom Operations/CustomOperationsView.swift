//
//  CustomOperationsView.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct OperationView: View {
    @StateObject var operationsManager = CustomOperationsManager.shared
    
    @State var operation: AdvancedObject
    
    @Binding var viewType: Int
    @Binding var currentOperation: AdvancedObject
    
    var body: some View {
        VStack {
            HStack {
                // MARK: Icon
                Group {
                    if let icn = operation.getImage() {
                        Image(nsImage: icn)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image("MissingCow")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(width: 50, height: 50)
                .cornerRadius(7)
                .padding(4)
                
                Spacer()
                
                VStack {
                    // MARK: Title
                    HStack {
                        Spacer()
                        Text(operation.name)
                            .bold()
                            .padding(.trailing, 1)
                        Text("v\(operation.version)")
                            .font(.footnote)
                            .opacity(0.8)
                    }
                    .padding(.top, 4)
                    .padding(.horizontal, 4)
                    
                    // MARK: Author
                    HStack {
                        Spacer()
                        if operation.author != "" {
                            Text(operation.author)
                                .font(.footnote)
                                .padding(.bottom, 4)
                                .padding(.horizontal, 4)
                        } else {
                            Text("No Author")
                                .font(.footnote)
                                .padding(.bottom, 4)
                                .padding(.horizontal, 4)
                        }
                    }
                    
                    // MARK: Enabled
                    HStack {
                        Spacer()
                        if (operation.enabled) {
                            Image(systemName: "checkmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            HStack {
                // MARK: Edit Button
                NiceButton(text: AnyView(
                    Text("Edit")
                        .frame(maxWidth: .infinity)
                ), action: {
                    currentOperation = operation
                    viewType = 1
                }, background: .blue)
                
                // MARK: Delete Button
                NiceButton(text: AnyView(
                    Image(systemName: "trash.fill")
                        .frame(maxWidth: 20)
                        .foregroundColor(.red)
                ), action: {
                    operationsManager.deleteOperation(name: operation.name)
                })
            }
        }
        .padding(10)
        .background(Color.cowGray)
        .cornerRadius(16)
    }
}

struct CustomOperationsView: View {
    var gridItemLayout = [GridItem(.adaptive(minimum: 170))]
    
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
                    }
                }
                
                Divider()
                
                HStack {
                    Spacer()
                    // MARK: Import Operation
                    NiceButton(text: AnyView(
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import .cowperation")
                        }
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
                    .padding(.bottom, 5)
                    
                    // MARK: Create New Operation
                    NiceButton(text: AnyView(
                        HStack {
                            Image(systemName: "plus")
                            Text("New Operation")
                        }
                    ), action: {
                        do {
                            currentOperation = try operationsManager.createOperation()
                            viewType = 1
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                    .padding(.trailing, 5)
                }
                
                if operationsManager.operations.count > 0 {
                    LazyVGrid(columns: gridItemLayout, spacing: 20) {
                        ForEach(operationsManager.operations) { operation in
                            OperationView(operation: operation, viewType: $viewType, currentOperation: $currentOperation)
                        }
                    }
                }
            }
        }
//        .disabled(!dataSingleton.deviceAvailable)
    }
}
